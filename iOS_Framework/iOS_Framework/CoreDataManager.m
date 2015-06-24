//
//  CoreDataManager.m
//  iOS_Framework
//
//  Created by Diplomat on 6/24/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "CoreDataManager.h"
#import "Constants.h"


@implementation CoreDataManager

- (id)initWithModeledDataNamed:(NSString *)name
{
    DLog();
    if ([super init])
    {
        [self initializeCoreDataWithModeledDataNamed:name];
    }
    
    return self;
}

- (void)initializeCoreDataWithModeledDataNamed:(NSString *)name
{
    DLog();
    [NSBundle bundleWithIdentifier:<#(NSString *)#>]
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"name" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",name]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        DLog();
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:0 error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}

- (void)saveContext
{
    DLog();
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
