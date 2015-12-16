//
//  AMBCoreDataDelegate.h
//  Ambassador
//
//  Created by Jake Dunahee on 12/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface AMBCoreDataDelegate : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (AMBCoreDataDelegate *)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
