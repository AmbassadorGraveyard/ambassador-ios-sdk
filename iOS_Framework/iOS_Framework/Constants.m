//
//  Constants.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

NSString * const AMB_IDENTIFY_NOTIFICATION_NAME = @"AMBIDENTNOTIF";

NSString * const AMB_IDENTIFY_STORAGE_KEY = @"AMBIDENTSTORAGE";

NSString * const AMB_IDENTIFY_URL = @"http://127.0.0.1:7999/augur.html?cbURL=ambassador:mylocation";

NSString * const AMB_IDENTIFY_JS_VAR = @"JSONdata";

NSString * const AMB_IDENTIFY_USER_DEFUALTS_KEY = @"AMBidentifyData";

NSString * const AMB_IDENTIFY_SIGNAL_URL = @"ambassador";

NSString * const AMB_INITIAL_BACKEND_REQUEST_URL = @"empty";



NSString * const AMB_CONVERSION_DB_NAME = @"conversions.db";

NSString * const AMB_CONVERSION_SQL_TABLE_NAME = @"conversions";

NSString * const AMB_CONVERSION_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/?u=***REMOVED***";

NSString * const AMB_CONVERSION_INSERT_QUERY = @"INSERT INTO Conversions VALUES(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

NSString * const AMB_MBSY_UNIVERSAL_ID = @"***REMOVED***";

NSString * const AMB_AUTHORIZATION_TOKEN = @"UniversalToken ***REMOVED***";

NSString * const AMB_CREATE_CONVERSION_TABLE = @"CREATE TABLE IF NOT EXISTS conversions (ID INTEGER PRIMARY KEY AUTOINCREMENT, mbsy_campaign INTEGER, mbsy_email TEXT, mbsy_first_name TEXT, mbsy_last_name TEXT, mbsy_email_new_ambassador INTEGER, mbsy_uid TEXT, mbsy_custom1 TEXT, mbsy_custom2 TEXT, mbsy_custom3 TEXT, mbsy_auto_create INTEGER, mbsy_revenue REAL, mbsy_deactivate_new_ambassador INTEGER, mbsy_transaction_uid TEXT, mbsy_add_to_group_id INTEGER, mbsy_event_data1 TEXT, mbsy_event_data2 TEXT, mbsy_event_data3 TEXT, mbsy_is_approved INTEGER)";



float const AMB_CONVERSION_FLUSH_TIME = 10.0;

float const AMB_IDENTIFY_RETRY_TIME = 2.0;





