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

@property NSMutableArray *apiResponse;
@property UIImageView *avatar;
@property UILabel *welcomeMessage;
@property UIButton *continueButton;
@property NSDictionary *viewsDictionary;

@end


@implementation AMB_WelcomeFullView

#pragma mark - Inits
- (id)init
{
    if ([super init])
    {
        //[self getAPIInfo];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder])
    {
        //[self getAPIInfo];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        //[self getAPIInfo];
    }
    
    return self;
}

- (void)getAPIInfo
{
    self.apiResponse = [[NSMutableArray alloc] init];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/welcome"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *e;
        NSMutableArray * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        if (!e)
        {
            self.apiResponse = json;
        }
    }] resume];
}

- (void)setup
{
    
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
