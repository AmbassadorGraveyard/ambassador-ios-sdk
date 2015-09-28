//
//  AMBCoreDataManager.m
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBCoreDataManager.h"
#import "AMBErrors.h"
#import "AMBUtilities.h"

// Identify
#import "AMBIdentifyCoreDataObject.h"

// User
#import "AMBUserUrlNetworkObject.h"
#import "AMBUserCoreDataObject.h"

// Conversion
#import "AMBConversionFieldsNetworkObject.h"
#import "AMBConversionFieldsCoreDataObject.h"

@interface AMBCoreDataManager ()
@property NSString *fileName;
@end

@implementation AMBCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// Core Data Entity Names;
NSString * const AMB_IDENTIFY_ENTITY_NAME = @"AMBIdentifyCoreDataObject";
NSString * const AMB_USER_ENTITY_NAME = @"AMBUserCoreDataObject";
NSString * const AMB_CONVERSION_FIELDS_ENTITY_NAME = @"AMBConversionFieldsCoreDataObject";


- (id)initWithFileName:(NSString *)fileName {
    if (self = [super init]) {
        self.fileName = fileName;
    }
    return self;
}

- (void)saveContext:(void (^)(NSError *))completion {
    __autoreleasing NSError *e = nil;
    NSManagedObjectContext *manObjCntx = self.managedObjectContext;
    if (manObjCntx != nil) {
        if ([manObjCntx hasChanges]) {
            [manObjCntx save:&e];
        }
        completion(e);
    } else {
        completion(AMBCDINVMOCError());
    }
}



#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Ambassador"  ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *modelPath = [bundle pathForResource:@"AMBCoreDataModel" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    assert(modelURL);
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;

}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
   
    NSString *pathCompnent = @"project.sqlite";
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:pathCompnent];
    NSLog(@"%@", storeURL);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    //TODO: THIS IS THE CHANGE
    BOOL test = NSClassFromString(@"XCTest") != nil;
    NSLog(@"Using in memory store: %i", test);
    NSString * storeType = test? NSInMemoryStoreType : NSSQLiteStoreType;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)rebuildCoreData {
    
    //[_managedObjectContext lock];
    [_managedObjectContext reset];
    
    NSArray *stores = _persistentStoreCoordinator.persistentStores;
    for (NSPersistentStore *currentStore in stores) {
        
        // remove store files
        [_persistentStoreCoordinator removePersistentStore:currentStore error:nil];
        
        // delete those store files
        [[NSFileManager defaultManager]removeItemAtURL:currentStore.URL error:nil];
    }
    
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    
    [self managedObjectContext];
    //[_managedObjectContext unlock];
}



#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



#pragma mark - Interface for Ambassador storage
- (void)saveIdentifyData:(AMBIdentifyNetworkObject *)obj completion:(void (^)(NSError *))completion {
    [self removeAllEntity:AMB_IDENTIFY_ENTITY_NAME completion:^(NSError *err) {
        AMBIdentifyCoreDataObject *identObj = [NSEntityDescription insertNewObjectForEntityForName:AMB_IDENTIFY_ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        NSError *e = nil;
        __weak AMBCoreDataManager *weakself = self;
        identObj.ambIdentifyNetworkObject = [NSJSONSerialization dataWithJSONObject:[obj dictionaryForm] options:0 error:&e];
        if (e) {
            [weakself throwCompletion:e block:completion];
        } else {
            [self saveContext:^(NSError *error) {
                [weakself throwCompletion:error block:completion];
            }];
        }
    }];
}

- (void)saveUserData:(AMBUserNetworkObject *)obj completion:(void (^)(NSError *))completion {
    [self removeAllEntity:AMB_USER_ENTITY_NAME completion:^(NSError *err) {
        AMBUserCoreDataObject *userObj = [NSEntityDescription insertNewObjectForEntityForName:AMB_USER_ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        NSError *e = nil;
        __weak AMBCoreDataManager *weakself = self;
        userObj.ambUserNetworkObject = [NSJSONSerialization dataWithJSONObject:[obj dictionaryForm] options:0 error:&e];
        if (e) {
            [weakself throwCompletion:e block:completion];
        } else {
            [self saveContext:^(NSError *err) {
                [weakself throwCompletion:err block:completion];
            }];
        }
    }];
}

- (void)saveConversionFields:(AMBConversionFieldsNetworkObject *)obj completion:(void (^)(NSError *))completion {
    NSError *e = [obj validate];
    if (e) {
        [self throwCompletion:e block:completion];
        return;
    }
    
    [self removeAllEntity:AMB_CONVERSION_FIELDS_ENTITY_NAME completion:^(NSError *err) {
        AMBConversionFieldsCoreDataObject *convObj = [NSEntityDescription insertNewObjectForEntityForName:AMB_CONVERSION_FIELDS_ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        NSError *e = nil;
        __weak AMBCoreDataManager *weakself = self;
        convObj.ambConversionFieldsNetworkObject = [NSJSONSerialization dataWithJSONObject:[obj dictionaryForm] options:0 error:&e];
        if (e) {
            [weakself throwCompletion:e block:completion];
        } else {
            [self saveContext:^(NSError *err) {
                [weakself throwCompletion:err block:completion];
            }];
        }
    }];
}

- (void)throwCompletion:(NSError *)e block:(void (^)(NSError *))b {
    if (b) {
        dispatch_async(dispatch_get_main_queue(), ^{ b(e); });
    }
}



# pragma mark - General item modifiers
- (void)getEntity:(NSString *)entity completion:(void (^)(NSArray *, NSError *))completion {
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSError *e;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&e];
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(results,e); });
    }
}

- (void)getConversionFields:(void (^)(NSArray *, NSError *))completion {
    [self getEntity:AMB_CONVERSION_FIELDS_ENTITY_NAME completion:completion];
}

- (void)removeAllEntity:(NSString *)entity completion:(void (^)(NSError *))completion {
    [self getEntity:entity completion:^(NSArray *results, NSError *e) {
        if (e) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(e); });
            }
            return;
        }
        for (int i = 0; i < results.count; ++i) {
            [self.managedObjectContext deleteObject:results[i]];
        }
        [self saveContext:^(NSError *err) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(err); });
            }
        }];
    }];
}

- (void)removeObject:(id)obj completion:(void (^)(NSError *))completion {
    [self.managedObjectContext deleteObject:obj];
    [self saveContext:^(NSError *err) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(err); });
        }
    }];
}

@end
