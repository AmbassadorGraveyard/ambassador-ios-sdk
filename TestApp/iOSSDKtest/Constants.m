//
//  Constants.m
//  Ambassador
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - URLs
NSString *const AMBASSADOR_IDENTIFY_URL = @"http://127.0.0.1:7999/augur.html?cbURL=ambassador:mylocation";
NSString *const AMBASSADOR_PREFERENCE_URL = @"http://localhost:3000/welcome";
NSString *const AMBASSADOR_CONVERSION_URL = @"";
NSString *const AMBASSADOR_IDENTIFY_SIGNAL_URL = @"ambassador";


#pragma mark - Error messages
NSString *const AMBASSADOR_JSON_PARSE_ERROR = @"Could not parse JSON data";
NSString *const AMBASSADOR_NETWORK_UNREACHABLE_ERROR = @"Could not reach the server";
NSString *const AMBASSADOR_NETWORK_TOO_MANY_REQUESTS_ERROR = @"Too many requests were made too quickly";
NSString *const AMBASSADOR_API_INVALID_ERROR = @"The API you entered is invalid. Check that you entered it correctly";
NSString *const AMBASSADOR_IDENTIFY_GENERAL_FAIL_ERROR_MESSAGE = @"Could not identify device";


#pragma mark - NSUserDefaults names
NSString *const AMBASSADOR_USER_DEFAULTS_APIKEY_KEY = @"ambassadorAPIKey";
NSString *const AMBASSADOR_USER_DEFAULTS_UIPREFERENCES_KEY = @"ambassadorUIPreferences";
NSString *const AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY = @"ambassadorIdentifyData";
NSString *const AMBASSADOR_USER_DEFAULTS_EVENT_QUEUE_KEY = @"ambassadorEventQueue";

#pragma mark - Variables
NSString *const AMBASSADOR_IDENTIFY_JAVASCRIPT_VARIABLE_NAME = @"JSONdata";

#pragma mark - NSNotificationCenter notification names
NSString *const AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION = @"ambassadorIdentifyDidCompleteNotification";


#pragma mark - Success messages
NSString *const AMBASSADOR_IDENTIFY_DATA_RECIEVED_SUCCESS = @"Identified device successfully";
NSString *const AMBASSADOR_PREFERENCES_DATA_RECIEVED_SUCCESS = @"UI preferences loaded successfully";
NSString *const AMBASSADOR_CONVERSION_DATA_RECIEVED_SUCCESS = @"Conversion return data recieved";

@end
