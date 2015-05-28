//
//  AMB_WelcomeFullView.m
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMB_WelcomeFullView.h"
#import <QuartzCore/QuartzCore.h>

@interface AMB_WelcomeFullView () <UITextViewDelegate>

@property NSDictionary *userInformation;
@property UIImageView *avatar;
@property UITextView *welcomeMessage;
@property UIButton *continueButton;
@property NSDictionary *viewsDictionary;

@end


@implementation AMB_WelcomeFullView

#pragma mark - Inits
- (id)init
{
    if ([super init])
    {
        [self setup];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder])
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    
    
    // TEMP //
    self.userInformation = @{
                                @"fromFirstName" : @"John",
                                @"fromLastName" : @"Doe",
                                @"toFirstName" : @"Jane",
                                @"toLastName" : @"Doe",
                                @"photoPath" : @"photo.jpg"
                            };
    
    
/*
--------------------------------------------------------------------------------
//TODO: Set these with the API
--------------------------------------------------------------------------------
*/

    /*
    --------------------
    Main view properties
    --------------------
    */
    self.mainViewBackgroundColor = [UIColor whiteColor];
    self.showAvatar = YES;
    self.showWelcomeMessage = YES;
    self.mainViewBorderColor = [UIColor clearColor];
    self.mainViewBorderWidth = 0.0f;
    
    /*
    -----------------
    Avatar properties
    -----------------
    */
    self.avatarBorderColor = [UIColor clearColor];
    self.avatarBorderWidth = 0.0f;
    
    /*
    --------------------------
    Welcome message properties
    --------------------------
    */
    self.welcomeMessageTextColor = [UIColor blackColor];
    self.welcomeMessageTextFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
    self.welcomeMessageBorderColor = [UIColor clearColor];
    self.welcomeMessageBorderWidth = 0.0f;
    self.welcomeMessageTextAllignment = NSTextAlignmentCenter;
    
    /*
    --------------------------
    Continue button properties
    --------------------------
    */
    self.continueButtonLabelText = @"Continue";
    self.continueButtonBackgroundColor = [UIColor clearColor];
    self.continueButtonLableTextColor = [UIColor blackColor];
    self.continueButtonLableTextFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.continueButtonBorderColor = [UIColor blackColor];
    self.continueButtonBorderWidth = 1.0f;
    
    /*
    ---------------------
    Storyboard properties
    ---------------------
    */
    self.segueIdentifier = @"moveFromWelcome";
    
    
/*
--------------------------------------------------------------------------------
=========================   Initialization of views   ==========================
--------------------------------------------------------------------------------
*/
    /*
    ------------------------
    Main view initialization
    ------------------------
    */
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    /*
    ---------------------
    Avatar initialization
    ---------------------
    */
    self.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.userInformation[@"photoPath"]]];
    self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatar.clipsToBounds = YES;
    self.avatar.layer.cornerRadius = 20;
    [self.view addSubview:self.avatar];
    
    /*
    ------------------------------
    Welcome message initialization
    ------------------------------
    */
    self.welcomeMessage = [[UITextView alloc] init];
    self.welcomeMessage.translatesAutoresizingMaskIntoConstraints = NO;
    self.welcomeMessage.editable = NO;
    self.welcomeMessage.text = [NSString stringWithFormat:@"Hi %@,\n Your friend %@ sent you here.\n\n Welcome!",
                                self.userInformation[@"toFirstName"],
                                self.userInformation[@"fromFirstName"]];
    [self.view addSubview:self.welcomeMessage];
    
    /*
    ------------------------------
    Welcome message initialization
    ------------------------------
    */
    self.continueButton = [[UIButton alloc] init];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton addTarget:self
                            action:@selector(continueButtonClicked)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.continueButton];
}


#pragma mark - View Controller Lifecycle
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
/*
--------------------------------------------------------------------------------
============================   Property Updates   ==============================
--------------------------------------------------------------------------------
*/
    
    /*
    --------------------------
    Main view property updates
    --------------------------
    */
    self.view.backgroundColor = self.mainViewBackgroundColor;
    
    /*
    -----------------------
    Avatar property updates
    -----------------------
    */
    self.avatar.layer.borderWidth = self.avatarBorderWidth;
    self.avatar.layer.borderColor = [self.avatarBorderColor CGColor];
    
    /*
    --------------------------------
    Welcome message property updates
    --------------------------------
    */
    self.welcomeMessage.textAlignment = self.welcomeMessageTextAllignment;
    self.welcomeMessage.font = self.welcomeMessageTextFont;
    self.welcomeMessage.textColor = self.welcomeMessageTextColor;
    self.welcomeMessage.layer.borderColor = [self.welcomeMessageBorderColor CGColor];
    self.welcomeMessage.layer.borderWidth = self.welcomeMessageBorderWidth;
    
    /*
    --------------------------------
    Continue button property updates
    --------------------------------
    */
    self.continueButton.backgroundColor = self.continueButtonBackgroundColor;
    self.continueButton.font = self.continueButtonLableTextFont;
    self.continueButton.layer.borderColor = [self.continueButtonBorderColor CGColor];
    self.continueButton.layer.borderWidth = self.continueButtonBorderWidth;
    [self.continueButton setTitle:self.continueButtonLabelText
                         forState:UIControlStateNormal];
    [self.continueButton setTitleColor:self.continueButtonLableTextColor
                              forState:UIControlStateNormal];
  
    
/*
--------------------------------------------------------------------------------
=========================   AutoLayout Constraints   ===========================
--------------------------------------------------------------------------------
*/
    
    /*
    ---------------------------------
    Dictionaries of metrics and names
    ---------------------------------
    */
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    self.viewsDictionary = @{
                              @"avatar" : self.avatar,
                              @"welcomeMessage" : self.welcomeMessage,
                              @"continueButton" : self.continueButton
                            };
    NSDictionary *metrics = @{
                              @"verticalPad" : [NSNumber numberWithFloat:screen.height * 0.1]
                            };
    
    /*
    ------------------
    Avatar constraints
    ------------------
    */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.2
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.2
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:50.0]];

    /*
    ---------------------------
    Welcome message constraints
    ---------------------------
    */
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar]-10-[welcomeMessage]-10-[continueButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.9
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0 constant:0.0]];
    
    /*
    ---------------------------
    Continue button constraints
    ---------------------------
    */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.continueButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.1
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.continueButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.5
                              
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.continueButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.continueButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-25.0]];
}


#pragma mark - Segues
- (void)continueButtonClicked {
    [self performSegueWithIdentifier:self.segueIdentifier sender:self];
}

@end
