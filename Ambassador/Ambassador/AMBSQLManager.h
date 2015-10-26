//
//  AMBSQLManager.h
//  Ambassador
//
//  Created by Diplomat on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBOptions.h"

@interface AMBSQLManager : NSObject
- (instancetype)initWithError:(NSError **)error;
- (void)saveObject:(id)object ofType:(AMBSQLStorageType)type completion:(void (^)(NSError *))completion;
- (void)deleteObjectOfType:(AMBSQLStorageType)type withID:(NSString *)ID completion:(void(^)(NSError *))completion;
- (NSString *)stringVersionOfTableType:(AMBSQLStorageType)type;
@end
