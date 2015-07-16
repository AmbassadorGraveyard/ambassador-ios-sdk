//
//  Constants.h
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#ifndef iOS_Framework_Constants_h
#define iOS_Framework_Constants_h

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

extern NSString * const AMB_IDENTIFY_NOTIFICATION_NAME;
extern NSString * const AMB_IDENTIFY_USER_DEFAULTS_KEY;
extern NSString * const AMB_AMBASSADOR_INFO_STORAGE_KEY;
extern NSString * const AMB_INSIGHTS_USER_DEFAULTS_KEY;
extern NSString * const AMB_MBSY_UNIVERSAL_ID;
extern NSString * const AMB_AUTHORIZATION_TOKEN;

#endif
