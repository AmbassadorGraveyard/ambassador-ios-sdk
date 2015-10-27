//
//  Constants.h
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#ifndef iOS_Framework_Constants_h
#define iOS_Framework_Constants_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - Notifications
extern NSString * const AMB_IDENTIFY_NOTIFICATION_NAME;



#pragma mark - UserDefaults
extern NSString * const AMB_IDENTIFY_USER_DEFAULTS_KEY;
extern NSString * const AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY;
extern NSString * const AMB_USER_EMAIL_DEFAULTS_KEY;
extern NSString * const AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY;
extern NSString * const AMB_UNIVERSAL_ID_DEFAULTS_KEY;
extern NSString * const AMB_CAMPAIGN_ID_DEFAULTS_KEY;
extern NSString * const AMB_INSIGHTS_USER_DEFAULTS_KEY;
extern NSString * const AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY;
extern NSString * const AMB_LINKEDIN_USER_DEFAULTS_KEY;



#pragma mark - Ambassador Back End
extern NSString * const AMB_AUTHORIZATION_TOKEN;
extern NSString * const AMB_SHARE_TRACK_URL;

extern NSString * const AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY;
extern NSString * const AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY;
extern NSString * const AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY;
extern NSString * const AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY;
extern NSString * const AMB_SMS_SHARE_URL;
extern NSString * const AMB_EMAIL_SHARE_URL;
extern NSString * const AMB_UPDATE_IDENTIFY_URL;



#pragma mark - Pusher
extern NSString * const AMB_PUSHER_KEY;
extern NSString * const AMB_PUSHER_AUTHENTICATION_URL;
extern NSString * const AMB_ERROR_DOMAIN;

#define ECPNIL  1   /* ConversionParameters property has nil value */
#define ECPPROP 2   /* ConversionParameters required properties unset */

#endif
