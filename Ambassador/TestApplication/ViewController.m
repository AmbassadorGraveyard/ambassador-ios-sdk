//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <Ambassador/Ambassador.h>

@interface ViewController () <AMBWelcomeScreenDelegate>

@property (nonatomic, strong) IBOutlet UIView * loginView;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UIButton * btnDrawer;
@property (nonatomic, strong) IBOutlet UITextField * tfUsername;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar;

@end

@implementation ViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpTheme];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLogin)];
    [longPress setMinimumPressDuration:0.3];
    [self.btnLogin setGestureRecognizers:@[longPress]];
}


#pragma mark - IBActions

- (IBAction)loginTapped:(id)sender {
    [self.view endEditing:YES];
    [self identifyOnSignIn];
}

- (void)longPressLogin {
    AMBWelcomeScreenParameters *welcomeParams = [[AMBWelcomeScreenParameters alloc] init];
    welcomeParams.detailMessage = @"You understand the value of referrals. Maybe you've even explored referral marketing software.";
    welcomeParams.referralMessage = @"John Doe has referred you to Ambassador";
    welcomeParams.accentColor = self.btnLogin.backgroundColor;
    welcomeParams.linkArray = @[@"Testimonials", @"Request Demo"];
    welcomeParams.actionButtonTitle = @"CREATE AN ACCOUNT";
    
    [AmbassadorSDK presentWelcomeScreen:self withParameters:welcomeParams];
}


#pragma mark - UI Functions

- (void)setUpTheme {    
    // Login View
    self.loginView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.signInCrossbar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.cornerRadius = 4;
    
    // Login Button
    self.btnLogin.layer.cornerRadius = 4;
}


#pragma mark - Helper Functions

- (void)identifyOnSignIn {
    if ([self allowSignIn]) {
        [AmbassadorSDK identifyWithEmail:self.tfUsername.text];
        [[NSUserDefaults standardUserDefaults] setValue:self.tfUsername.text forKey:@"loginEmail"];
    } else {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"Cannot log in" message:@"All fields must be filled out before signing in" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [blankAlert show];
    }
}

- (BOOL)allowSignIn {
    return (![self.tfPassword.text  isEqual: @""] && ![self.tfUsername.text  isEqual: @""]) ? YES : NO;
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

@end
