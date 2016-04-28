//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "IdentifyViewController.h"
#import <Ambassador/Ambassador.h>
#import "DefaultsHandler.h"
#import "AmbassadorLoginViewController.h"
#import "Validator.h"
#import "ValuesHandler.h"
#import "FileWriter.h"
#import <ZipZap/ZipZap.h>
#import "UIActivityViewController+ZipShare.h"

@interface IdentifyViewController () <AMBWelcomeScreenDelegate>

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
        // Creates a new directiry in the documents folder
        NSString *filePath = [[FileWriter documentsPath] stringByAppendingPathComponent:@"ambassador-identify.zip"];
        
        // Creates a new zip file containing all different files
        ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
        [newArchive updateEntries:@[[self getObjectiveFile:email], [self getSwiftFile:email], [self getJavaFile:email]] error:nil];
        
        // Creates a url that returns an actual file
        NSURL *fileurl = [NSURL fileURLWithPath:filePath];
        
        // Shows a share sheet with the zip file attached
        [UIActivityViewController shareZip:fileurl withMessage:[FileWriter readMeForRequest:ReadmeTypeIdentify containsImage:nil] subject:@"Ambassador Identify Implementation" forPresenter:self];
        
        return;
    }
    
    [self showValidationError:@"exporting"];
}

// Creates an Objective-C App Delegate file
- (ZZArchiveEntry *)getObjectiveFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithEmail:@\"%@\"]; \n\n", email];
    NSString *objectiveCString = [FileWriter objcAppDelegateFileWithInsert:identifyString];
 
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objectiveCString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

// Creates a Swift App Delegate file
- (ZZArchiveEntry *)getSwiftFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithEmail(\"%@\") \n\n", email];
    NSString *swiftString = [FileWriter swiftAppDelegateFileWithInsert:identifyString];

    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

// Creates an example Java file
- (ZZArchiveEntry *)getJavaFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identify(\"%@\"); \n", email];
    NSString *javaString = [FileWriter javaMyApplicationFileWithInsert:identifyString];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (void)showValidationError:(NSString*)action {
    UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [invalidEmailAlert show];
}

@end
