//
//  Conversion.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Conversion.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "Constants.h"

NSString *AMB_CREATE_CONVERSION_TABLE = @"CREATE TABLE IF NOT EXISTS conversions (ID INTEGER PRIMARY KEY AUTOINCREMENT, mbsy_campaign INTEGER, mbsy_email TEXT, mbsy_first_name TEXT, mbsy_last_name TEXT, mbsy_email_new_ambassador INTEGER, mbsy_uid TEXT, mbsy_custom1 TEXT, mbsy_custom2 TEXT, mbsy_custom3 TEXT, mbsy_auto_create INTEGER, mbsy_revenue REAL, mbsy_deactivate_new_ambassador INTEGER, mbsy_transaction_uid TEXT, mbsy_add_to_group_id INTEGER, mbsy_event_data1 TEXT, mbsy_event_data2 TEXT, mbsy_event_data3 TEXT, mbsy_is_approved INTEGER)";

@interface Conversion ()

@property NSString *databaseName;
@property NSString *libraryDirectoryPath;
@property NSString *databaseFilePath;

@end

@implementation Conversion

- (id)init
{
    DLog();
    if ([super init])
    {
        self.databaseName = @"Conversions.db";
        self.libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        self.databaseFilePath = [self.libraryDirectoryPath stringByAppendingString:self.databaseName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.databaseFilePath])
        {
            DLog(@"Database file needs to be created");
            FMDatabase *database = [FMDatabase databaseWithPath:self.databaseFilePath];
            [database open];
            if ([database executeUpdate:AMB_CREATE_CONVERSION_TABLE])
            {
                DLog(@"Create 'Conversions' table succeeded");
            }
            else
            {
                DLog(@"Create 'Conversions' table failed");
            }
            [database close];
        }
    }
    
    return self;
}

- (void)registerConversionWithParameters:(ConversionParameters *)parameters
{
    DLog();
    if (![parameters isValid])
    {
        //TODO: Throw an exception so developers know to take care of this
        DLog(@"***INVALID PARAMETERS PASSED***");
        return;
    }
    
    DLog(@"Valid parameters passed");
    FMDatabase *database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    if ([database executeUpdate:@"INSERT INTO Conversions VALUES(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
                             parameters.mbsy_campaign,
                             parameters.mbsy_email,
                             parameters.mbsy_first_name,
                             parameters.mbsy_last_name,
                             parameters.mbsy_email_new_ambassador,
                             parameters.mbsy_uid,
                             parameters.mbsy_custom1,
                             parameters.mbsy_custom2,
                             parameters.mbsy_custom3,
                             parameters.mbsy_auto_create,
                             parameters.mbsy_revenue,
                             parameters.mbsy_deactivate_new_ambassador,
                             parameters.mbsy_transaction_uid,
                             parameters.mbsy_add_to_group_id,
                             parameters.mbsy_event_data1,
                             parameters.mbsy_event_data2,
                             parameters.mbsy_event_data3,
                             parameters.mbsy_is_approved])
    {
        DLog(@"Insert conversion successful");
        
    }
    else
    {
        DLog(@"Insert conversion failed");
    }
    [database close];
    
}

- (void)sendConversions
{
    DLog();
    NSURL *url = [NSURL URLWithString:@"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/?u=abfd1c89-4379-44e2-8361-ee7b87332e32"];
    
    //TODO: make network call and put the following code in completion block
    FMDatabase * database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM Conversions"];
    while ([resultSet next])
    {
        
        NSDictionary *jsonData = @{
                                   @"fields" :
                                       @{
                                           @"mbsy_campaign": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_campaign"]],
                                           @"mbsy_email": [resultSet stringForColumn:@"mbsy_email"],
                                           @"mbsy_first_name": [resultSet stringForColumn:@"mbsy_first_name"],
                                           @"mbsy_last_name": [resultSet stringForColumn:@"mbsy_last_name"],
                                           @"mbsy_email_new_ambassador": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_email_new_ambassador"]],
                                           @"mbsy_uid": [resultSet stringForColumn:@"mbsy_uid"],
                                           @"mbsy_custom1": [resultSet stringForColumn:@"mbsy_custom1"],
                                           @"mbsy_custom2": [resultSet stringForColumn:@"mbsy_custom2"],
                                           @"mbsy_custom3": [resultSet stringForColumn:@"mbsy_custom3"],
                                           @"mbsy_auto_create": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_auto_create"]],
                                           @"mbsy_revenue": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_revenue"]],
                                           @"mbsy_deactivate_new_ambassador": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_deactivate_new_ambassador"]],
                                           @"mbsy_transaction_uid": [resultSet stringForColumn:@"mbsy_transaction_uid"],
                                           @"mbsy_add_to_group_id": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_add_to_group_id"]],
                                           @"mbsy_event_data1": [resultSet stringForColumn:@"mbsy_event_data1"],
                                           @"mbsy_event_data2": [resultSet stringForColumn:@"mbsy_event_data2"],
                                           @"mbsy_event_data3": [resultSet stringForColumn:@"mbsy_event_data3"],
                                           @"mbsy_is_approved": [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_is_approved"]]
                                           }//,

                                   };
        __autoreleasing NSError *e = nil;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&e];
        if (!e)
        {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"POST";
            request.HTTPBody = JSONData;
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"abfd1c89-4379-44e2-8361-ee7b87332e32" forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
            [request setValue:@"UniversalToken bdb49d2b9ae24b7b6bc5da122370f3517f98336f" forHTTPHeaderField:@"Authorization"];
            
            // Create a task.
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                         completionHandler:^(NSData *data,
                                                                                             NSURLResponse *response,
                                                                                             NSError *error)
                                          {
                                              if (!error)
                                              {
                                                  NSLog(@"Status code: %li", (long)((NSHTTPURLResponse *)response).statusCode);
                                                  DLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                              }
                                              else
                                              {
                                                  NSLog(@"Error: %@", error.localizedDescription);
                                              }
                                          }];
            
            // Start the task.
            [task resume];

        }
    }
    [database close];
    [self emptyDatabase];
}

- (BOOL)shouldSendConversions
{
    DLog();
    FMDatabase *database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM Conversions"];
    [database close];
    while ([resultSet next]) { return YES; }
    
    return NO;
}

- (void)emptyDatabase
{
    DLog();
    FMDatabase * database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    [database executeStatements:@"DELETE FROM Conversions"];
    [database close];

}

- (void)attachInsightsDataToID:(int)ID
{
    
}

@end
