//
//  AMBCoreDataManager.m
//  Ambassador
//
//  Created by Jake Dunahee on 12/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBCoreDataManager.h"
#import "AMBCoreDataDelegate.h"

@implementation AMBCoreDataManager

#pragma mark - SAVE Funtionality

+ (void)saveNewObjectToCoreDataWithEntityName:(NSString *)entityTypeToSave valuesToSave:(NSDictionary *)valuesDict {
    NSManagedObjectContext *context = [[AMBCoreDataDelegate sharedInstance] managedObjectContext];
    NSEntityDescription *entdesc = [NSEntityDescription entityForName:entityTypeToSave inManagedObjectContext:context];
    NSManagedObject *managedObject = [[NSManagedObject alloc]initWithEntity:entdesc insertIntoManagedObjectContext:context];
    NSArray *dictionaryValues = [valuesDict allKeys];
    
    for (NSString *key in dictionaryValues) {
        [managedObject setValue:valuesDict[key] forKey:key];
    }
    
    [[AMBCoreDataDelegate sharedInstance] saveContext];
}


#pragma mark - GETTER Functionality

+ (NSMutableArray*)getAllEntitiesFromCoreDataWithEntityName:(NSString *)entityName alphabetizeByProperty:(NSString *)property{
    NSManagedObjectContext *context = [[AMBCoreDataDelegate sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    
    //Returns entities in alphabetical order based on a certain property
    if (property) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:property ascending:YES];
        NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:descriptors];
    }
    
    NSError *error;
    if (error) { DLog(@"Error getting CoreData Object - %@", error); }
    
    return [[context executeFetchRequest:request error:&error] mutableCopy];
}

+ (NSMutableArray*)getAllEntitiesFromCoreDataWithEntityName:(NSString *)entityName {
    return [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:entityName alphabetizeByProperty:nil];
}


#pragma mark - DELETE Functionality

+ (void)deleteCoreDataObject:(NSManagedObject*)managedObject {
    NSManagedObjectContext *context = [[AMBCoreDataDelegate sharedInstance] managedObjectContext];
    [context deleteObject:managedObject];
    NSError *error;
    [context save:&error];
}

@end
