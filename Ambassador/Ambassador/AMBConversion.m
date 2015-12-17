//
//  Conversion.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

//#import "NamespacedDependencies.h"
#import "AMBConversion.h"
#import "AMBFMResultSet.h"
#import "AMBFMDatabase.h"
#import "AMBFMDatabaseQueue.h"
#import "AMBConstants.h"
#import "AMBUtilities.h"
#import "AMBCoreDataManager.h"
#import "AMBConversionParametersEntity.h"

#pragma mark - Local Constants
NSString * const AMB_CONVERSION_DB_NAME = @"conversions.db";
NSString * const AMB_CONVERSION_SQL_TABLE_NAME = @"conversions";

#if AMBPRODUCTION
NSString * const AMB_CONVERSION_URL = @"https://api.getambassador.com/universal/action/conversion/";
#else
NSString * const AMB_CONVERSION_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/";
#endif
NSString * const AMB_CONVERSION_INSERT_QUERY = @"INSERT INTO Conversions VALUES(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
NSString * const AMB_CREATE_CONVERSION_TABLE = @"CREATE TABLE IF NOT EXISTS conversions (ID INTEGER PRIMARY KEY AUTOINCREMENT, mbsy_campaign INTEGER, mbsy_email TEXT, mbsy_first_name TEXT, mbsy_last_name TEXT, mbsy_email_new_ambassador INTEGER, mbsy_uid TEXT, mbsy_custom1 TEXT, mbsy_custom2 TEXT, mbsy_custom3 TEXT, mbsy_auto_create INTEGER, mbsy_revenue REAL, mbsy_deactivate_new_ambassador INTEGER, mbsy_transaction_uid TEXT, mbsy_add_to_group_id INTEGER, mbsy_event_data1 TEXT, mbsy_event_data2 TEXT, mbsy_event_data3 TEXT, mbsy_is_approved INTEGER, insights_data BLOB)";

NSString * const AMB_ADD_SHORT_CODE_COLUMN = @"ALTER TABLE conversions ADD COLUMN mbsy_short_code TEXT";
#pragma mark -



@interface AMBConversion ()

@property NSString *databaseName;
@property NSString *libraryDirectoryPath;
@property NSString *databaseFilePath;
@property AMBFMDatabaseQueue *databaseQueue;
@property AMBFMDatabase *database;

@end



@implementation AMBConversion

#pragma mark - Initialization
- (id)initWithKey:(NSString *)key
{
    DLog();
    if ([super init])
    {
        self.key = key;
        
        // Build file path for the database file and log it
        self.databaseName = AMB_CONVERSION_DB_NAME;
        self.libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        self.databaseFilePath = [self.libraryDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@", self.databaseName]];
        DLog(@"Database file for viewing at: %@", self.databaseFilePath);
        
        // Check if the file exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.databaseFilePath])
        {
            DLog(@"Database file needs to be created");
            self.database = [AMBFMDatabase databaseWithPath:self.databaseFilePath];
            
            [self.database open];
            
            // Run the SQL query to create the Conversions table
            if ([self.database executeUpdate:AMB_CREATE_CONVERSION_TABLE])
            {
                DLog(@"Create 'Conversions' table succeeded");
            }
            else
            {
                DLog(@"Create 'Conversions' table failed");
            }
            [self.database close];
        }
        
        // Set the database queue to point to database file
        self.databaseQueue = [AMBFMDatabaseQueue databaseQueueWithPath:self.databaseFilePath];
    }
    
    return self;
}



#pragma mark - API Functions

- (void)registerConversionWithParameters:(AMBConversionParameters *)parameters completion:(void (^)(NSError *error))completion {
    NSLog(@"[Ambassador] Attempting to save conversion -\n%@", [parameters description]);
    NSError *error = [parameters checkForError];
    
    if (!error) { [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]]; }
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

- (void)sendConversions {
    // If no device fingerprint is available, an empty dictionary will be returned
    NSDictionary *userDefaultsIdentify = [AMBValues getDeviceFingerPrint];

    // Checks to make sure we have either a short code OR device fingerprint before moving on
    if ([[AMBValues getMbsyCookieCode] isEqualToString:@""] && [userDefaultsIdentify isEqual:@{}]) {
        return;
    }
    
    NSArray *storedConversionArray = [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:@"AMBConversionParametersEntity"];
    
    if ([storedConversionArray count] > 0) {
        for (AMBConversionParametersEntity *entity in storedConversionArray) {
            AMBConversionParameters *parameters = [[AMBConversionParameters alloc] initWithEntity:entity];
            NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionaryWithDictionary:[parameters propertyDictionary]];
            [fieldsDictionary setValue:[AMBValues getMbsyCookieCode] forKey:@"mbsy_short_code"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self payloadForConversionCallWithFP:userDefaultsIdentify mbsyFields:fieldsDictionary] options:0 error:nil];
            
            //Create the POST request
            NSURL *url = [NSURL URLWithString:AMB_CONVERSION_URL];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:self.key forHTTPHeaderField:@"Authorization"];
            request.HTTPBody = jsonData;

            NSURLSession *urlSession;
            
            #if AMBPRODUCTION
                urlSession = [NSURLSession sharedSession];
            #else
                urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
            #endif
            
            NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    DLog(@"CONVERSION CALL - Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                    
                    if ([AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse *)response).statusCode]) {
                        DLog(@"Response from backend for CONVERSION CALL = %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                    } else {
                        NSLog(@"[Ambassador] Error - Server reponse from sending conversion:%ld - %@", (long)((NSHTTPURLResponse *)response).statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                    }
                    
                    return;
                }
                
                DLog(@"CONVERSION CALL Error: %@", error.localizedDescription);
            }];
            
            [task resume];
        }
    }
}


#pragma mark - NSURL Delegete

// Allows certain requests to be made for dev servers when running in unit tests for Circle
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if([challenge.protectionSpace.host isEqualToString:@"dev-ambassador-api.herokuapp.com"]) { // Makes sure that it's our url being challenged
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}


#pragma mark - Helper Functions

- (NSDictionary*)payloadForConversionCallWithFP:(NSDictionary*)deviceFingerprint mbsyFields:(NSMutableDictionary*)mbsyFields {
    // If we DON'T have a device fingerprint, we set the 'fp' value to empty set the fields to the mbsy fields
    if (!deviceFingerprint || deviceFingerprint.count == 0) { return @{@"fp" : @{}, @"fields" : mbsyFields}; }
    
    NSDictionary *consumerDict = @{@"UID" : deviceFingerprint[@"consumer"][@"UID"], @"insights" : (deviceFingerprint[@"consumer"][@"insights"]) ? deviceFingerprint[@"consumer"][@"insights"] : @{}};
    NSDictionary *deviceDict = @{@"type" : deviceFingerprint[@"device"][@"type"], @"ID" : deviceFingerprint[@"device"][@"ID"]};
    NSDictionary *fingerPrintDict = @{@"consumer" : consumerDict, @"device" : deviceDict };
    
    return @{@"fp" : fingerPrintDict, @"fields" : mbsyFields };
}

@end
