//
//  Constants.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);

NSString * const AMB_IDENTIFY_NOTIFICATION_NAME = @"AMBIDENTNOTIF";
NSString * const AMB_IDENTIFY_STORAGE_KEY = @"AMBIDENTSTORAGE";
NSString * const AMB_IDENTIFY_URL = @"http://127.0.0.1:7999/augur.html?cbURL=ambassador:mylocation";
NSString * const AMB_IDENTIFY_JS_VAR = @"JSONdata";
NSString * const AMB_IDENTIFY_USER_DEFUALTS_KEY = @"AMBidentifyData";
NSString * const AMB_IDENTIFY_SIGNAL_URL = @"ambassador";
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
float const AMB_IDENTIFY_RETRY_TIME = 2.0;