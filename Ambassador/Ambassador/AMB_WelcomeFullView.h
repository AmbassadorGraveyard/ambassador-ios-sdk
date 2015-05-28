//
//  AMB_WelcomeFullView.h
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMB_WelcomeFullView : UIViewController

//Main view properties
@property UIColor *mainViewBackgroundColor;
@property BOOL showAvatar;
@property BOOL showWelcomeMessage;
@property UIColor *mainViewBorderColor;
@property CGFloat mainViewBorderWidth;

//Avatar properties
@property UIColor *avatarBorderColor;
@property CGFloat avatarBorderWidth;

//Welcome message properties
@property UIColor *welcomeMessageTextColor;
@property UIFont *welcomeMessageTextFont;
@property UIColor *welcomeMessageBorderColor;
@property CGFloat welcomeMessageBorderWidth;
@property NSTextAlignment welcomeMessageTextAllignment;

//Continue button properties
@property NSString *continueButtonLabelText;
@property UIColor *continueButtonBackgroundColor;
@property UIColor *continueButtonLableTextColor;
@property UIFont *continueButtonLableTextFont;
@property UIColor *continueButtonBorderColor;
@property CGFloat continueButtonBorderWidth;

//Storyboard properties
@property NSString *segueIdentifier;


@end
