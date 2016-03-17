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

@interface IdentifyViewController () <AMBWelcomeScreenDelegate>

@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UITextField * tfEmail;
@property (nonatomic, strong) IBOutlet UIView * imageBGView;

@end


@implementation IdentifyViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpTheme];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLogin)];
    [longPress setMinimumPressDuration:0.3];
    [self.btnSubmit setGestureRecognizers:@[longPress]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.title = @"Identify";
}


#pragma mark - IBActions

- (IBAction)loginTapped:(id)sender {
    [self.tfEmail resignFirstResponder];
    [self identify];
}

- (void)longPressLogin {
    AMBWelcomeScreenParameters *welcomeParams = [[AMBWelcomeScreenParameters alloc] init];
    welcomeParams.detailMessage = @"You understand the value of referrals. Maybe you've even explored referral marketing software.";
    welcomeParams.referralMessage = @"{{ name }} has referred you to Ambassador";
    welcomeParams.accentColor = self.btnSubmit.backgroundColor;
    welcomeParams.linkArray = @[@"Testimonials", @"Request Demo"];
    welcomeParams.actionButtonTitle = @"CREATE AN ACCOUNT";
    
    [AmbassadorSDK presentWelcomeScreen:self withParameters:welcomeParams];
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


#pragma mark - Helper Functions

- (void)identify {
    [AmbassadorSDK identifyWithEmail:self.tfEmail.text];
}

@end
