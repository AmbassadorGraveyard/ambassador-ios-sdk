//
//  AMB_WelcomeFullView.m
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMB_WelcomeFullView.h"

@interface AMB_WelcomeFullView ()

@property NSDictionary *userInformation;
@property NSDictionary *styleOptions;
@property UIImageView *avatar;
@property UITextView *welcomeMessage;
@property UIButton *continueButton;

@property UIView *redView;
@property UIView *yellowView;
@property NSDictionary *viewsDictionary;

@end


@implementation AMB_WelcomeFullView

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor orangeColor];
    /*
    ---------------------
    Avatar initialization
    ---------------------
    */
    self.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.jpg"]];
    self.avatar.backgroundColor = [UIColor grayColor];
    self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.avatar];
    
    /*
    ------------------------------
    Welcome message initialization
    ------------------------------
    */
    self.welcomeMessage = [[UITextView alloc] init];
    self.welcomeMessage.backgroundColor = [UIColor clearColor];
    self.welcomeMessage.translatesAutoresizingMaskIntoConstraints = NO;
    self.welcomeMessage.text = @"Hi John,\nYour friend Bob sent you here.\n\nWelcome!";
    self.welcomeMessage.textAlignment = NSTextAlignmentCenter;
    self.welcomeMessage.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
    self.welcomeMessage.textColor = [UIColor whiteColor];
    [self.view addSubview:self.welcomeMessage];
    
    /*
    ------------------------------
    Welcome message initialization
    ------------------------------
    */
    self.continueButton = [[UIButton alloc] init];
    [self.continueButton setTitle:@"Continue"
                         forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor orangeColor]
                              forState:UIControlStateNormal];
    self.continueButton.backgroundColor = [UIColor whiteColor];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton addTarget:self
                            action:@selector(continueButtonClicked)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.continueButton];
    
    /*
    ------------------
    Dictionary of view
    ------------------
    */
    self.viewsDictionary = @{ @"avatar" : self.avatar,
                              @"welcomeMessage" : self.welcomeMessage,
                              @"continueButton" : self.continueButton
                            };
    
    /* 
    ------------------
    Avatar constraints
    ------------------
    */
    NSArray *avatarConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar(75)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:self.viewsDictionary];
    NSArray *avatarConstraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[avatar(75)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:self.viewsDictionary];
    [self.avatar addConstraints:avatarConstraintsH];
    [self.avatar addConstraints:avatarConstraintsV];
    NSArray *avatarConstraintsPOSX = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[avatar]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:self.viewsDictionary];
    [self.view addConstraints:avatarConstraintsPOSX];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                          attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    /*
    ---------------------------
    Welcome message constraints
    ---------------------------
    */
    NSDictionary *metrics = @{@"vSpacing":@30, @"hSpacing":@10};
    NSArray *welcomeMessageConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-vSpacing-[welcomeMessage]-vSpacing-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:self.viewsDictionary];
    NSArray *welcomeMessageConstraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[welcomeMessage(200)]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:self.viewsDictionary];
    NSArray *welcomeMessagePOSY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar]-15-[welcomeMessage]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:self.viewsDictionary];
    [self.view addConstraints:welcomeMessageConstraintsH];
    [self.view addConstraints:welcomeMessagePOSY];
    [self.welcomeMessage addConstraints:welcomeMessageConstraintsV];
    
    /*
    ---------------------------
    Continue button constraints
    ---------------------------
    */
    NSArray *continueButtonConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-vSpacing-[continueButton]-vSpacing-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:self.viewsDictionary];
    NSArray *continueButtonPOSY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[continueButton]-50-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:self.viewsDictionary];
    [self.view addConstraints:continueButtonConstraintsH];
    [self.view addConstraints:continueButtonPOSY];
}

- (void)continueButtonClicked {
    UIViewController *to = [self.storyboard instantiateViewControllerWithIdentifier:@"test"];
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"continueButton" source:self destination:to];
    [segue perform];
}

@end


//self.userInformation = @{	@"refererFirstName": @"John",
//                            @"refererLastName": @"Doe",
//                            @"refererPhotoPath": @"/Users/diplomat/photo.jpg",
//                            @"refereeFirstName": @"Jane",
//                            @"refererLastName": @"Doe",
//                            @"customMessage": @"Welcome!!!"
//                            };
//
//CGSize screen = [[UIScreen mainScreen] bounds].size;
//
////The avatar image view
//UIImage *avatarImage = [UIImage imageNamed:@"photo.jpg"];
//
//self.avatar = [[UIImageView alloc] initWithImage:avatarImage];
//self.avatar.frame = CGRectMake((screen.width / 2) - 50, 75, 100, 100);
////self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
//self.avatar.backgroundColor = [UIColor grayColor];
//
//[self.view addSubview:self.avatar];
//
////The welcome message text view
//self.welcomeMessage = [[UITextView alloc] initWithFrame:CGRectMake(25, 250, screen.width - 50, screen.height - 450)];
//self.welcomeMessage.translatesAutoresizingMaskIntoConstraints = NO;
//self.welcomeMessage.backgroundColor = [UIColor greenColor];
//[self.view addSubview:self.welcomeMessage];
//
////The continue button
//self.continueButtom = [[UIButton alloc] initWithFrame:CGRectMake(25, 525, screen.width - 50, 50)];
//[self.continueButtom setTitle:@"Continue" forState:UIControlStateNormal];
////self.continueButtom.translatesAutoresizingMaskIntoConstraints = NO;
//self.continueButtom.backgroundColor = [UIColor grayColor];
//
//[self.view addSubview:self.continueButtom];
