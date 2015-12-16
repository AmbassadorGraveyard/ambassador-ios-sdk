//
//  AMBCoreDataManager.m
//  Ambassador
//
//  Created by Jake Dunahee on 12/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "AMBCoreDataDelegate.h"

@implementation AMBCoreDataManager

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

@end
