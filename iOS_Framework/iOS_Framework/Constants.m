//
//  Constants.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
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

#if AMBPRODUCTION
NSString * const AMB_PUSHER_AUTHENTICATION_URL = @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";
# else
NSString * const AMB_PUSHER_AUTHENTICATION_URL = @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/"; //Change to production
# endif

NSString * const AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY = @"AMBFIRSTLAUNCHSTORAGE";

NSString * const AMB_RAF_SHARE_SERVICES_TITLE = @"Refer your friends";

NSString * const AMB_CLOSE_BUTTON_NAME = @"close.png";

NSString * const AMB_BACK_BUTTON_NAME = @"back.png";

NSString * const AMB_LINKEDIN_USER_DEFAULTS_KEY = @"AMBLINKEDINSTORAGE";

#if AMBPRODUCTION
NSString * const AMB_SHARE_TRACK_URL = @"https://dev-ambassador-api.herokuapp.com/track/share/";
#else
NSString * const AMB_SHARE_TRACK_URL = @"https://dev-ambassador-api.herokuapp.com/track/share/"; //Change to production
#endif

NSString * const AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY = @"short_code";

NSString * const AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY = @"recipient_email";

NSString * const AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY = @"social_name";

NSString * const AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY = @"recipient_username";

#if AMBPRODUCTION
NSString * const AMB_SMS_SHARE_URL = @"https://dev-ambassador-api.herokuapp.com/share/sms/";
#else
NSString * const AMB_SMS_SHARE_URL = @"https://dev-ambassador-api.herokuapp.com/share/sms/"; //Change to production
#endif

#if AMBPRODUCTION
NSString * const AMB_EMAIL_SHARE_URL = @"https://dev-ambassador-api.herokuapp.com/share/email/";
#else
NSString * const AMB_EMAIL_SHARE_URL = @"https://dev-ambassador-api.herokuapp.com/share/email/"; //Change to production
#endif

#if AMBPRODUCTION
NSString * const AMB_UPDATE_IDENTIFY_URL = @"http://dev-ambassador-api.herokuapp.com/universal/action/identify/";
#else
NSString * const AMB_UPDATE_IDENTIFY_URL = @"http://dev-ambassador-api.herokuapp.com/universal/action/identify/"; //Change to production
#endif
