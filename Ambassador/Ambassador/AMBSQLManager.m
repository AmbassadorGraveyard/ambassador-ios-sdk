//
//  AMBSQLManager.m
//  Ambassador
//
//  Created by Diplomat on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBSQLManager.h"
#import "AMBFMResultSet.h"
#import "AMBFMDatabase.h"
#import "AMBFMDatabaseQueue.h"
#import "AMBErrors.h"

NSString * const AMB_CREATE_CONVERSION_TABLES = @"CREATE IF NOT EXISTS conversions (ID INTEGER PRIMARY KEY AUTOINCREMENT, conversion_fields BLOB NOT NULL);";

@interface AMBSQLManager ()
@property AMBFMDatabase *database;
@property AMBFMDatabaseQueue *databaseQueue;
@end

@implementation AMBSQLManager
-(instancetype)initWithError:(NSError **)error {
    if (self = [super init]) {
        // check if the file exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self databaseFileDirectory]]) {
            // create file
            self.database = [AMBFMDatabase databaseWithPath:[self databaseFileDirectory]];
            [self.database open];
            // run the scripts to create tables
            if (![self.database executeUpdate:AMB_CREATE_CONVERSION_TABLES]) {
                AMBSQLINITFAILError([self databaseFileDirectory]);
            }
            [self.database close];
        }
        self.databaseQueue = [AMBFMDatabaseQueue databaseQueueWithPath:[self databaseFileDirectory]];
    }
    return self;
}

- (NSString *)databaseFileDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/AMBAmbassadorDatabase.db"]];
}

- (void)saveObjectWithError:(NSError *)error {
    [self.databaseQueue inDatabase:^(AMBFMDatabase *db) {
        [db executeUpdate:@"INSERT INTO conversions"];
    }];
}


@end
