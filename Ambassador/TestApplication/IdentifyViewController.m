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
#import "FileWriter.h"

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
        // Creates a mail compose message to share via email with snippet and plist attachment
        MFMailComposeViewController *mailVc = [[MFMailComposeViewController alloc] init];
        mailVc.mailComposeDelegate = self;
        [mailVc addAttachmentData:[self getReadmeFile] mimeType:@"application/txt" fileName:@"README.md"];
        [mailVc addAttachmentData: [self getObjectiveFile: email] mimeType:@"application/txt" fileName:@"AppDelegate.m"];
        [mailVc addAttachmentData: [self getSwiftFile:email] mimeType:@"application/txt" fileName:@"AppDelegate.swift"];
        [mailVc addAttachmentData:[self getJavaFile:email] mimeType:@"application/txt" fileName:@"MyApplication.java"];
        [mailVc setSubject:@"Ambassador Identify Code"];
        [self presentViewController:mailVc animated:YES completion:nil];
        
        return;
    }
    
    [self showValidationError:@"exporting"];
}

// Creates an Objective-C App Delegate file
- (NSData *)getObjectiveFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithEmail:@\"%@\"]; \n\n", email];
    NSString *objectiveCString = [FileWriter objcAppDelegateFileWithInsert:identifyString];
 
    return [objectiveCString dataUsingEncoding:NSUTF8StringEncoding];
}

// Creates a Swift App Delegate file
- (NSData *)getSwiftFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithEmail(\"%@\") \n\n", email];
    NSString *swiftString = [FileWriter swiftAppDelegateFileWithInsert:identifyString];

    
    return [swiftString dataUsingEncoding:NSUTF8StringEncoding];
}

// Creates an example Java file
- (NSData *)getJavaFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identify(\"%@\"); \n", email];
    NSString *javaString = [FileWriter javaMyApplicationFileWithInsert:identifyString];
    
    return [javaString dataUsingEncoding:NSUTF8StringEncoding];
}

// Create README file
- (NSData *)getReadmeFile {
    NSString *readmeFileString = [FileWriter readMeForRequest:@"identify"];
    return [readmeFileString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)showValidationError:(NSString*)action {
    UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [invalidEmailAlert show];
}

@end
