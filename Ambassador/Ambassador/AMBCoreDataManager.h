//
//  AMBCoreDataManager.h
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AMBIdentifyNetworkObject.h"
#import "AMBUserNetworkObject.h"
#import "AMBConversionFieldsNetworkObject.h"

@interface AMBCoreDataManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext:(void(^)(NSError *))completion;

//- (NSURL *)applicationDocumentsDirectory;

- (void)rebuildCoreData;

- (void)saveIdentifyData:(AMBIdentifyNetworkObject *)obj completion:(void(^)(NSError *))completion;

- (void)saveUserData:(AMBUserNetworkObject *)obj completion:(void (^)(NSError *))completion;

- (void)saveConversionFields:(AMBConversionFieldsNetworkObject *)obj completion:(void (^)(NSError *))completion;

- (void)getEntity:(NSString *)entity completion:(void (^)(NSArray *results, NSError *e))completion;
- (void)getConversionFields:(void (^)(NSArray *results, NSError *e))completion;

//
//- (void)removeAllEntity:(NSString *)entity completion:(void(^)(NSError *))completion;
//
- (void)removeObject:(id)obj completion:(void(^)(NSError *))completion;
@end
