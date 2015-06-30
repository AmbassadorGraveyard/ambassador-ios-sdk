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
extern NSString * const AMB_IDENTIFY_STORAGE_KEY;
extern NSString * const AMB_IDENTIFY_URL;
extern NSString * const AMB_IDENTIFY_JS_VAR;
extern NSString * const AMB_IDENTIFY_USER_DEFUALTS_KEY;
extern NSString * const AMB_IDENTIFY_SIGNAL_URL;
extern NSString * const AMB_INITIAL_BACKEND_REQUEST_URL;

extern NSString * const AMB_CONVERSION_DB_NAME;
extern NSString * const AMB_CONVERSION_SQL_TABLE_NAME;
extern NSString * const AMB_CONVERSION_URL;
extern NSString * const AMB_CONVERSION_SELECT_ALL_QUERY;
extern NSString * const AMB_CONVERSION_DELETE_ALL_QUERY;
extern NSString * const AMB_CONVERSION_INSERT_QUERY;
extern NSString * const AMB_MBSY_UNIVERSAL_ID;
extern NSString * const AMB_AUTHORIZATION_TOKEN;
extern NSString * const AMB_CREATE_CONVERSION_TABLE;

extern float const AMB_CONVERSION_FLUSH_TIME;
extern float const AMB_IDENTIFY_RETRY_TIME;

#endif
