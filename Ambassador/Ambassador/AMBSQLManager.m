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
#import "AMBOptions.h"
#import "AMBNetworkObject.h"

@implementation AMBSQLResult
@end

@interface AMBSQLManager ()
@property AMBFMDatabase *database;
@property AMBFMDatabaseQueue *databaseQueue;
@end

@implementation AMBSQLManager
- (instancetype)initWithError:(NSError **)error {
    if (self = [super init]) {
        // check if the file exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self databaseFileDirectory]]) {
            // create file
            self.database = [AMBFMDatabase databaseWithPath:[self databaseFileDirectory]];
            [self.database open];
            // run the scripts to create tables
            if (![self.database executeUpdate:[self createTableQueryForSQLStorageType:AMBSQLStorageTypeConversions]]) {
                AMBSQLINITFAILError([self databaseFileDirectory]);
            }
            [self.database close];
        }
        self.databaseQueue = [AMBFMDatabaseQueue databaseQueueWithPath:[self databaseFileDirectory]];
    }
    return self;
}

- (void)saveObject:(id)object ofType:(AMBSQLStorageType)type completion:(void (^)(NSError *e))completion {
    __weak AMBSQLManager *weakSelf = self;
    [self.databaseQueue inDatabase:^(AMBFMDatabase *db) {
        NSError *e = nil;
        NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
        if(![db executeUpdate:[weakSelf insertQueryForSQLStorageType:type], objectData]) {
            e = AMBSQLSAVEFAILError();
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(e); });
        }
    }];
}

- (void)selectAllOfType:(AMBSQLStorageType)type completion:(void(^)(NSMutableArray *, NSError *))completion {
    __weak AMBSQLManager *weakSelf = self;
    [self.databaseQueue inDatabase:^(AMBFMDatabase *db) {
        NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
        AMBFMResultSet *results = [db executeQuery:[weakSelf selectAllQueryForSQLStorageType:type]];
        while ([results next]) {
            AMBSQLResult *result = [[AMBSQLResult alloc] init];
            result.ID = [results intForColumn:@"id"];
            result.object = [results dataForColumn:@"object"];
            [resultsArr addObject:result];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(resultsArr, nil); });
        }
    }];
}

- (void)deleteObjectOfType:(AMBSQLStorageType)type withID:(int)ID completion:(void(^)(NSError *))completion {
    __weak AMBSQLManager *weakSelf = self;
    [self.databaseQueue inDatabase:^(AMBFMDatabase *db) {
        NSError *e = nil;
        if(![db executeUpdate:[weakSelf deleteQueryForSQLStorageType:type withID:ID]]) {
            e = AMBSQLSAVEFAILError();
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(e); });
        }
    }];
}



#pragma mark - template functions
- (NSString *)databaseFileDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/AMBAmbassadorDatabase.db"]];
}

- (NSString *)insertQueryForSQLStorageType:(AMBSQLStorageType)type {
    return [NSString stringWithFormat:@"INSERT INTO %@ VALUES(null, ?);", sqlStorageTypeStringVal(type)];
}

- (NSString *)createTableQueryForSQLStorageType:(AMBSQLStorageType)type {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, object BLOB NOT NULL);", sqlStorageTypeStringVal(type)];
}

- (NSString *)deleteQueryForSQLStorageType:(AMBSQLStorageType)type withID:(int)ID {
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@.id=%i;", sqlStorageTypeStringVal(type), sqlStorageTypeStringVal(type), ID];
}

- (NSString *)selectAllQueryForSQLStorageType:(AMBSQLStorageType)type {
    return [NSString stringWithFormat:@"SELECT * FROM %@;", sqlStorageTypeStringVal(type)];
}



#pragma mark - printing
- (NSString *)stringVersionOfTableType:(AMBSQLStorageType)type {
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM %@;", sqlStorageTypeStringVal(type)];
    [self.databaseQueue inDatabase:^(AMBFMDatabase *db) {
        AMBFMResultSet *resultSet = [db executeQuery:selectQuery];
        while ([resultSet next]) {
            NSData *obj = [resultSet dataForColumn:@"object"];
            AMBConversionFields *conversion = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            NSLog(@"%i | %@", [resultSet intForColumn:@"id"], conversion);
        }
        [resultSet close];
    }];
    return nil;
}

@end
