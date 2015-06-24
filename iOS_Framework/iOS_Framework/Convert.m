//
//  Convert.m
//  iOS_Framework
//
//  Created by Diplomat on 6/24/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Convert.h"
#import "CoreDataManager.h"
#import "Constants.h"

@interface Convert ()

@property CoreDataManager *coreDataManager;

@end

@implementation Convert

- (id)init
{
    DLog();
    if ([super init])
    {
        self.coreDataManager = [[CoreDataManager alloc] initWithModeledDataNamed:@"Conversions"];
    }
    
    return self;
}

- (void)registerConversion:(Conversion *)conversion
{
    DLog();
    Conversion *contextConversion = [NSEntityDescription insertNewObjectForEntityForName:@"Conversion"
                                                                  inManagedObjectContext:self.coreDataManager.managedObjectContext];
    contextConversion = conversion;
    [self.coreDataManager saveContext];
}

- (void)sendConversions
{
    
}

- (void)removeLocalConversions
{
    DLog();
    [self.coreDataManager.managedObjectContext deletedObjects];
    [self.coreDataManager saveContext];
}

- (BOOL)shouldSendConversions
{
    DLog();
    return YES;
}

@end
