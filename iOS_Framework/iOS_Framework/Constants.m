//
//  Constants.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Utilities.h"

NSString * const AMB_IDENTIFY_NOTIFICATION_NAME = @"AMBIDENTNOTIF";

NSString * const AMB_IDENTIFY_USER_DEFAULTS_KEY = @"AMBIDENTSTORAGE";

NSString * const AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY = @"AMBAMBASSADORINFOSTORAGE";

NSString * const AMB_INSIGHTS_USER_DEFAULTS_KEY = @"AMBINSIGHTSSTORAGE";

NSString * const AMB_MBSY_UNIVERSAL_ID = @"***REMOVED***";

NSString * const AMB_AUTHORIZATION_TOKEN = @"UniversalToken ***REMOVED***";

NSString * const AMB_PUSHER_KEY = @"***REMOVED***";

NSString * const AMB_PUSHER_AUTHENTICATION_URL = @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";

NSString * const AMB_RAF_SHARE_SERVICES_TITLE = @"Refer your friends";

NSString * const AMB_CLOSE_BUTTON_NAME = @"close.png";

NSString * const AMB_BACK_BUTTON_NAME = @"back.png";

NSString * const AMB_LINKEDIN_USER_DEFAULTS_KEY = @"AMBLINKEDINSTORAGE";

CGRect AMB_CLOSE_BUTTON_FRAME()
{
    return CGRectMake(0, 0, 14, 14);
}

UIColor* AMB_NAVIGATION_BAR_TINT_COLOR()
{
    return [UIColor blackColor];
}

UIFont* DEFAULT_FONT_SMALL()
{
    return [UIFont systemFontOfSize:12];
}

UIFont* DEFAULT_FONT_XSMALL()
{
    return [UIFont systemFontOfSize:10];
}

UIFont* DEFAULT_FONT()
{
    return [UIFont systemFontOfSize:16];
}

UIFont* DEFAULT_FONT_LARGE()
{
    return [UIFont systemFontOfSize:18];
}

UIColor* FACEBOOK_COLOR()
{
    return ColorFromRGB(59, 89, 152);
}

UIColor* TWITTER_COLOR()
{
    return ColorFromRGB(85, 172, 238);
}

UIColor* LINKEDIN_COLOR()
{
    return ColorFromRGB(0, 119, 181);
}

UIColor* DEFAULT_GRAY_COLOR()
{
    return ColorFromRGB(170, 170, 170);
}

UIColor* DEFAULT_LIGHT_GRAY_COLOR()
{
    return ColorFromRGB(241, 241, 241);
}

UIColor* CLEAR_COLOR()
{
    return [UIColor clearColor];
}

UIColor* DEFAULT_FADE_VIEW_COLOR(bool black)
{
    return black? [UIColor colorWithWhite:0.0 alpha:0.5] :
                  [UIColor colorWithWhite:1.0 alpha:0.65];
}

NSString * const LINKEDIN_ERROR_KEY = @"error";
NSString * const LINKEDIN_CODE_KEY = @"code";
NSString * const LINKEDIN_EXPIRES_KEY = @"expires_in";
NSString * const LINKEDIN_ACCESS_TOKEN_KEY = @"access_token";



#pragma mark - Image Names
NSString * const BACK_IMAGE_NAME = @"back.png";
NSString * const CHECK_IMAGE_NAME = @"check.png";
NSString * const PENCIL_IMAGE_NAME = @"pencil.png";
NSString * const COPY_IMAGE_NAME = @"clipboard.png";
NSString * const FB_IMAGE_NAME = @"facebook.png";
NSString * const TWTR_IMAGE_NAME = @"twitter.png";
NSString * const LKDN_IMAGE_NAME = @"linkedin.png";
NSString * const SMS_IMAGE_NAME = @"sms.png";
NSString * const EMAIL_IMAGE_NAME = @"email.png";
NSString * const SEARCH_IMAGE_NAME = @"search.png";
