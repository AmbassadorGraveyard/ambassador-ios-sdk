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
        // Create a code snippet based on the info entered into the identify field
        NSString *titleString = [NSString stringWithFormat:@"Ambassador Identify Code Snippet v%@", [ValuesHandler getVersionNumber]];
        NSString *objcCodeSnippet = [NSString stringWithFormat:@"[AmbassadorSDK identifyWithEmail:@\"%@\"];", email];
        NSString *swiftCodeSnippet = [NSString stringWithFormat:@"AmbassadorSDK.identifyWithEmail(\"%@\")", email];
        NSString *fullCodeSnippet = [NSString stringWithFormat:@"Objective-C\n\n%@\n\n\nSwift\n\n%@", objcCodeSnippet, swiftCodeSnippet];
        
        NSString *shareString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@", titleString, fullCodeSnippet]];
        
        // Package up snippet to share
        NSArray * shareItems = @[shareString];
        UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
        [avc setValue:@"Ambassador Identify Code Snippet" forKey:@"subject"];
        [self presentViewController:avc animated:YES completion:nil];
        
        return;
    }
    
    [self showValidationError:@"exporting"];
}

- (void)showValidationError:(NSString*)action {
    UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [invalidEmailAlert show];
}

@end
