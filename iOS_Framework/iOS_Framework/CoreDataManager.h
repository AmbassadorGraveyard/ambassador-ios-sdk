//
//  CoreDataManager.h
//  iOS_Framework
//
//  Created by Diplomat on 6/24/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject


@property (strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithModeledDataNamed:(NSString *)name;
- (void)saveContext;

@end
