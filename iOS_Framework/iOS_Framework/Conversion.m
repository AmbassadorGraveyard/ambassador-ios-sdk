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
    //TODO: make network call and put the following code in completion block
    FMDatabase * database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM Conversions"];
    ConversionParameters *parameters = [[ConversionParameters alloc] init];
    [database close];
    [self emptyDatabase];
}

- (BOOL)shouldSendConversions
{
    FMDatabase *database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM Conversions"];
    [database close];
    while ([resultSet next]) { return YES; }
    
    return NO;
}

- (void)emptyDatabase
{
    FMDatabase * database = [FMDatabase databaseWithPath:self.databaseFilePath];
    [database open];
    [database executeStatements:@"DELETE FROM Conversions"];
    [database close];

}

@end
