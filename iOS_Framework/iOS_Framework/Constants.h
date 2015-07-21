//
//  Constants.h
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#ifndef iOS_Framework_Constants_h
#define iOS_Framework_Constants_h

#import <UIKit/UIKit.h>

#pragma mark - Notifications
extern NSString * const AMB_IDENTIFY_NOTIFICATION_NAME;



#pragma mark - UserDefaults
extern NSString * const AMB_IDENTIFY_USER_DEFAULTS_KEY;
extern NSString * const AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY;
extern NSString * const AMB_INSIGHTS_USER_DEFAULTS_KEY;
extern NSString * const AMB_LINKEDIN_USER_DEFAULTS_KEY;



#pragma mark - Ambassador Back End
extern NSString * const AMB_MBSY_UNIVERSAL_ID;
extern NSString * const AMB_AUTHORIZATION_TOKEN;



#pragma mark - Pusher
extern NSString * const AMB_PUSHER_KEY;
extern NSString * const AMB_PUSHER_AUTHENTICATION_URL;



#pragma mark - UIDefaults
extern NSString * const AMB_RAF_SHARE_SERVICES_TITLE;
extern NSString * const AMB_CLOSE_BUTTON_NAME;
extern NSString * const AMB_BACK_BUTTON_NAME;
CGRect AMB_CLOSE_BUTTON_FRAME();
UIColor* AMB_NAVIGATION_BAR_TINT_COLOR();
UIFont* DEFAULT_FONT_SMALL();
UIFont* DEFAULT_FONT_XSMALL();
UIFont* DEFAULT_FONT();
UIFont* DEFAULT_FONT_LARGE();
UIColor* FACEBOOK_COLOR();
UIColor* TWITTER_COLOR();
UIColor* LINKEDIN_COLOR();
UIColor* DEFAULT_GRAY_COLOR();
UIColor* DEFAULT_LIGHT_GRAY_COLOR();
UIColor* CLEAR_COLOR();
UIColor* DEFAULT_FADE_VIEW_COLOR(bool black);



#pragma mark - LinkedIn
extern NSString * const LINKEDIN_ERROR_KEY;
extern NSString * const LINKEDIN_CODE_KEY;
extern NSString * const LINKEDIN_EXPIRES_KEY;
extern NSString * const LINKEDIN_ACCESS_TOKEN_KEY;

#endif
