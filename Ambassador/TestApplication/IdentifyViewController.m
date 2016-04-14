//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "IdentifyViewController.h"
#import <MessageUI/MessageUI.h>
#import <Ambassador/Ambassador.h>
#import "DefaultsHandler.h"
#import "AmbassadorLoginViewController.h"
#import "Validator.h"
#import "ValuesHandler.h"

@interface IdentifyViewController () <AMBWelcomeScreenDelegate, MFMailComposeViewControllerDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UITextField * tfEmail;
@property (nonatomic, strong) IBOutlet UIView * imageBGView;
@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;

// Private properties
@property (nonatomic, strong) NSString * codeExportString;

@end


@implementation IdentifyViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpTheme];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.title = @"Identify";
    [self addExportButton];
    [self registerForKeyboardNotificaitons];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - IBActions

- (IBAction)submitTapped:(id)sender {
    [self identify];
    [self.tfEmail resignFirstResponder];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"Message sent successfully!");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Message failed to send");
            break;
        default:
            NSLog(@"Message was not sent");
            break;
    }
}


#pragma mark - WelcomeScreen Delegate

- (void)welcomeScreenActionButtonPressed:(UIButton *)actionButton {
    UIAlertView *actionAlert = [[UIAlertView alloc] initWithTitle:@"Action Button" message:@"You pressed the action button on the welcome screen" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [actionAlert show];
}

- (void)welcomeScreenLinkPressedAtIndex:(NSInteger)linkIndex {
    UIAlertView *linkAlert = [[UIAlertView alloc] initWithTitle:@"Link Tapped" message:[NSString stringWithFormat:@"You tapped a link at index %li", (long)linkIndex] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [linkAlert show];
}


#pragma mark - Keyboard Listener

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.tfEmail.frame.origin.y + 10;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    
    if (keyboardFrame.size.height > difference) {
        CGFloat newY = keyboardFrame.size.height - difference;
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Resets the scrollview to original position
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - UI Functions

- (void)setUpTheme {
    // TextFields
    self.tfEmail.tintColor = self.btnSubmit.backgroundColor;
    
    // Sets padding for text/placeholder text
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.tfEmail.leftView = paddingView;
    self.tfEmail.leftViewMode = UITextFieldViewModeAlways;
    
    // Login Button
    self.btnSubmit.layer.cornerRadius = 5;
    
    // Images
    self.imageBGView.layer.cornerRadius = 5;
}

- (void)addExportButton {
    UIBarButtonItem *btnExport = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exportIconSm"] style:UIBarButtonItemStylePlain target:self action:@selector(exportCode)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnExport;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Helper Functions

- (void)identify {
    NSString *email = self.tfEmail.text;
    
    if ([Validator isValidEmail:email]) {
        [AmbassadorSDK identifyWithEmail:self.tfEmail.text];
        
        NSString *confirmationMessage = [NSString stringWithFormat:@"You have succesfully identified as %@! You can now track conversion events and create commissions!", email];
        UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:@"Great!" message:confirmationMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [confirmationAlert show];
        
        return;
    }
    
    [self showValidationError:@"identifying"];
    
}

- (void)exportCode {
    [self.tfEmail resignFirstResponder];
    NSString *email = self.tfEmail.text;
    
    if ([Validator isValidEmail:email]) {
        // Create a code snippet based on the info entered into the identify field
        NSString *titleString = [NSString stringWithFormat:@"Ambassador Identify Code Snippet v%@", [ValuesHandler getVersionNumber]];
        
        // Creates a mail compose message to share via email with snippet and plist attachment
        MFMailComposeViewController *mailVc = [[MFMailComposeViewController alloc] init];
        mailVc.mailComposeDelegate = self;
        [mailVc addAttachmentData: [self getObjectiveFile: email] mimeType:@"application/txt" fileName:@"AppDelegate.m"];
        [mailVc addAttachmentData: [self getSwiftFile:email] mimeType:@"application/txt" fileName:@"AppDelegate.swift"];
        [mailVc setSubject:titleString];
        [self presentViewController:mailVc animated:YES completion:nil];
        
        return;
    }
    
    [self showValidationError:@"exporting"];
}

// Creates an Objective-C App Delegate file
- (NSData *)getObjectiveFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"    [AmbassadorSDK runWithUniversalToken:\"%@\" universalID:\"%@\"]; \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    NSString *identifyString = [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithEmail:@\"%@\"]; \n\n", email];
    
    // Builds Objective-C implementation file
    NSMutableString *objectiveCString = [[NSMutableString alloc] init];
    [objectiveCString appendString: @"#import \"AppDelegate.h\" \n"];
    [objectiveCString appendString: @"#import <Ambassador/Ambassador.h> \n\n"];
    [objectiveCString appendString: @"@interface AppDelegate () \n\n"];
    [objectiveCString appendString: @"@end \n\n"];
    [objectiveCString appendString: @"@implementation AppDelegate \n\n"];
    [objectiveCString appendString: @"- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { \n"];
    [objectiveCString appendString: runWithKeysString];
    [objectiveCString appendString:identifyString];
    [objectiveCString appendString:@"    return YES; \n"];
    [objectiveCString appendString:@"} \n\n"];
    [objectiveCString appendString: @"@end"];
    
    return [objectiveCString dataUsingEncoding:NSUTF8StringEncoding];
}

// Creates a Swift App Delegate file
- (NSData *)getSwiftFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithUniversalToken(\"%@\", universalID: \"%@\") \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithEmail(\"%@\") \n\n", email];
    
    // Builds Swift file
    NSMutableString *swiftString = [[NSMutableString alloc] init];
    [swiftString appendString:@"import UIKit \n\n"];
    [swiftString appendString:@"@UIApplicationMain"];
    [swiftString appendString:@"class AppDelegate: UIResponder, UIApplicationDelegate { \n\n"];
    [swiftString appendString:@"    var window: UIWindow? \n\n\n"];
    [swiftString appendString:@"    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool { \n"];
    [swiftString appendString:runWithKeysString];
    [swiftString appendString:identifyString];
    [swiftString appendString:@"        return true \n"];
    [swiftString appendString:@"    } \n"];
    [swiftString appendString:@"}"];
    
    return [swiftString dataUsingEncoding:NSUTF8StringEncoding];
}

// Creates an example Java file
- (NSData *)getJavaFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithKeys(this, \"SDKToken %@\", \"%@\"); \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identify(\"%@\"); \n", email];
    
    // Builds Java file
    NSMutableString *javaString = [[NSMutableString alloc] init];
    [javaString appendString:@"package com.example.example; \n\n"];
    [javaString appendString:@"import android.app.Application; \n"];
    [javaString appendString:@"import com.ambassador.ambassadorsdk.ConversionParameters; \n"];
    [javaString appendString:@"import com.ambassador.ambassadorsdk.AmbassadorSDK; \n\n"];
    [javaString appendString:@"public class MyApplication extends Application { \n\n"];
    [javaString appendString:@"    @Override \n"];
    [javaString appendString:@"    public void onCreate() { \n"];
    [javaString appendString:@"        super.onCreate(); \n"];
    [javaString appendString:runWithKeysString];
    [javaString appendString:identifyString];
    [javaString appendString:@"    } \n"];
    [javaString appendString:@"}"];
    
    return [javaString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)showValidationError:(NSString*)action {
    UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [invalidEmailAlert show];
}

@end
