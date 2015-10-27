//
//  AMBSQLManager.h
//  Ambassador
//
//  Created by Diplomat on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBOptions.h"
#import "AMBFMResultSet.h"

@interface AMBSQLResult : NSObject
@property int ID;
@property NSData *object;
@end

@interface AMBSQLManager : NSObject
- (instancetype)initWithError:(NSError **)error;
- (void)saveObject:(id)object ofType:(AMBSQLStorageType)type completion:(void (^)(NSError *))completion;
- (void)selectAllOfType:(AMBSQLStorageType)type completion:(void(^)(NSMutableArray *, NSError *))completion;
- (void)deleteObjectOfType:(AMBSQLStorageType)type withID:(int)ID completion:(void(^)(NSError *))completion;
- (NSString *)stringVersionOfTableType:(AMBSQLStorageType)type;
@end
