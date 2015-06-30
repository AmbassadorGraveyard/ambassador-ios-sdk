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
#import "FMDatabaseQueue.h"
#import "Constants.h"

@interface Conversion ()

@property NSString *databaseName;
@property NSString *libraryDirectoryPath;
@property NSString *databaseFilePath;

@property FMDatabaseQueue *databaseQueue;
@property FMDatabase *database;

@end



@implementation Conversion

- (id)init
{
    DLog();
    if ([super init])
    {
        self.databaseName = AMB_CONVERSION_DB_NAME;
        self.libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        self.databaseFilePath = [self.libraryDirectoryPath stringByAppendingString:self.databaseName];
        DLog(@"%@", self.databaseFilePath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.databaseFilePath])
        {
            DLog(@"Database file needs to be created");
            self.database = [FMDatabase databaseWithPath:self.databaseFilePath];
            [self.database open];
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

        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.databaseFilePath];
    }
    
    return self;
}

- (void)registerConversionWithParameters:(ConversionParameters *)parameters
{
    DLog();
    if (![parameters isValid])
    {
        [NSException raise:@"Invalid conversion parameters"
                    format:@"Conversion parameters must have set values for 'mbsy_revenue' (NSNumber *), 'mbsy_campaign' (NSNumber *), and 'mbsy_email' (NSString *)"];
    }
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
    {
        [db executeUpdate:AMB_CONVERSION_INSERT_QUERY,
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
         parameters.mbsy_is_approved,
         NULL];
    }];
}

- (void)sendConversions
{
    DLog();
    NSDictionary *userDefaultsIdentify = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_IDENTIFY_USER_DEFUALTS_KEY];
    NSDictionary *userDefaultsInsights = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
    if (!userDefaultsInsights) { return; }
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
    {
        DLog(@"In database queue");
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", AMB_CONVERSION_SQL_TABLE_NAME]];
        
        while ([resultSet next])
        {
            NSMutableDictionary * fields = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                            @"mbsy_campaign" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_campaign"]],
                                                                                            @"mbsy_email" : [resultSet stringForColumn:@"mbsy_email"],
                                                                                            @"mbsy_first_name" : [resultSet stringForColumn:@"mbsy_first_name"],
                                                                                            @"mbsy_last_name" : [resultSet stringForColumn:@"mbsy_last_name"],
                                                                                            @"mbsy_email_new_ambassador" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_email_new_ambassador"]],
                                                                                            @"mbsy_uid" : [resultSet stringForColumn:@"mbsy_uid"],
                                                                                            @"mbsy_custom1" : [resultSet stringForColumn:@"mbsy_custom1"],
                                                                                            @"mbsy_custom2" : [resultSet stringForColumn:@"mbsy_custom2"],
                                                                                            @"mbsy_custom3" : [resultSet stringForColumn:@"mbsy_custom3"],
                                                                                            @"mbsy_auto_create" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_auto_create"]],
                                                                                            @"mbsy_revenue" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_revenue"]],
                                                                                            @"mbsy_deactivate_new_ambassador" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_deactivate_new_ambassador"]],
                                                                                            @"mbsy_transaction_uid" : [resultSet stringForColumn:@"mbsy_transaction_uid"],
                                                                                            @"mbsy_add_to_group_id" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_add_to_group_id"]],
                                                                                            @"mbsy_event_data1" : [resultSet stringForColumn:@"mbsy_event_data1"],
                                                                                            @"mbsy_event_data2" : [resultSet stringForColumn:@"mbsy_event_data2"],
                                                                                            @"mbsy_event_data3" : [resultSet stringForColumn:@"mbsy_event_data3"],
                                                                                            @"mbsy_is_approved" : [NSNumber numberWithInt:[resultSet intForColumn:@"mbsy_is_approved"]]
                                                                                            }];
            
                NSDictionary * consumer = @{
                                            @"UID" : userDefaultsIdentify[@"consumer"][@"UID"],
                                            @"insights" : userDefaultsInsights
                                            };
                NSDictionary * device = @{
                                          @"type" : userDefaultsIdentify[@"device"][@"type"],
                                          @"ID" : userDefaultsIdentify[@"device"][@"ID"]
                                          };
                
                [fields removeObjectForKey:@"insights"];
                NSDictionary * payload = @{
                                           @"fp" : @{
                                                   @"consumer" : consumer,
                                                   @"device" : device
                                                   },
                                           @"fields" : fields
                                           };
                
                DLog(@"WE HAVE INSIGHTS DATA");
                
                // URL of the endpoint we're going to contact.
                NSURL *url = [NSURL URLWithString:AMB_CONVERSION_URL];
                
                // Convert the dictionary into JSON data.
                NSData *JSONData = [NSJSONSerialization dataWithJSONObject:payload
                                                                   options:0
                                                                     error:nil];
                
                // Create a POST request with our JSON as a request body.
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                request.HTTPMethod = @"POST";
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
                [request setValue:AMB_AUTHORIZATION_TOKEN forHTTPHeaderField:@"Authorization"];
                request.HTTPBody = JSONData;
                
                // Create a task.
                NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                             completionHandler:^(NSData *data,
                                                                                                 NSURLResponse *response,
                                                                                                 NSError *error)
                                              {
                                                  if (!error)
                                                  {
                                                      NSLog(@"Status code: %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                      DLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                                      DLog(@"%i", [resultSet intForColumn:@"ID"]);
                                                      [db executeQuery:@"Delete from conversions where ID = ?", [resultSet intForColumn:@"ID"]];
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"Error: %@", error.localizedDescription);
                                                  }
                                              }];
                
                [task resume];
        }
    }];
}

@end

































