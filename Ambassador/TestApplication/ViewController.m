//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <Ambassador/Ambassador.h>
#import "DefaultsHandler.h"
#import "AmbassadorLoginViewController.h"

@interface ViewController () <AMBWelcomeScreenDelegate, AmbassadorLoginDelegate>

@property (nonatomic, strong) IBOutlet UIView * loginView;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UITextField * tfUsername;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar;
@property (nonatomic) BOOL hasPerformedRunWithKeys;

@end


@implementation ViewController

NSString * loginSegue = @"ambassador_login_segue";


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpTheme];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLogin:)];
//    [longPress setMinimumPressDuration:0.6];
    [self.btnLogin addGestureRecognizer:longPress];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.hasPerformedRunWithKeys) {
        [self checkForLogin];
    }
}


#pragma mark - IBActions

- (IBAction)loginTapped:(id)sender {
    [self.view endEditing:YES];
    [self identifyOnSignIn];
}

- (void)longPressLogin:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        AMBWelcomeScreenParameters *welcomeParams = [[AMBWelcomeScreenParameters alloc] init];
        welcomeParams.detailMessage = @"You understand the value of referrals. Maybe you've even explored referral marketing software.";
        welcomeParams.referralMessage = @"{{ name }} has referred you to Ambassador";
        welcomeParams.accentColor = self.btnLogin.backgroundColor;
        welcomeParams.linkArray = @[@"Testimonials", @"Request Demo"];
        welcomeParams.actionButtonTitle = @"CREATE AN ACCOUNT";
        
        [AmbassadorSDK presentWelcomeScreen:welcomeParams ifAvailable:^(AMBWelcomeScreenViewController *welcomeScreenVC) {
            [self presentViewController:welcomeScreenVC animated:YES completion:nil];
        }];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:loginSegue]) {
        AmbassadorLoginViewController *loginVC = (AmbassadorLoginViewController*)segue.destinationViewController;
        loginVC.delegate = self;
    }
}


#pragma mark - Ambassador Login Delegate

- (void)userSuccessfullyLoggedIn {
    [self checkForLogin];
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

- (void)checkForLogin {
    if ([[DefaultsHandler getSDKToken] isEqualToString:@""] || [[DefaultsHandler getUniversalID] isEqualToString:@""]) {
        [self performSegueWithIdentifier:loginSegue sender:self];
    } else {
        self.hasPerformedRunWithKeys = YES;
        [AmbassadorSDK runWithUniversalToken:[DefaultsHandler getSDKToken] universalID:[DefaultsHandler getUniversalID]];
    }
}

@end
