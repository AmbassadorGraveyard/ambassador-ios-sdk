//
//  interface.m
//  fileInterface
//
//  Created by Diplomat on 6/4/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "interface.h"

@implementation interface

- (NSString *)getPathDirectory
{
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    return [paths stringByAppendingPathComponent:@"AmbassadorDocuments"];
}

- (BOOL)setUpAmbassadorDocumentsDirectory
{
    __autoreleasing NSError *e;
    NSString *path = [self getPathDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&e])
        {
            NSLog(@"Error creating AmbassadorDocuments directory");
            return NO;
        }
        else
        {
            NSLog(@"Created AmbassadorDocuments directory");
            return YES;
        }
    }
    else
    {
        NSLog(@"AmbassadorDocuments directory found");
        return YES;
    }
}

- (NSMutableArray*)writeArray:(NSArray *)addArray toQueue:(NSString *)queueName
{
    NSString *path = [self getPathDirectory];
    path = [path stringByAppendingPathComponent:queueName];
    NSMutableArray *queue;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"Queue file found");
        queue = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (addArray)
        {
            [queue addObjectsFromArray:addArray];
        }
    }
    else
    {
        NSLog(@"Queue file not found");
        if (addArray)
        {
            queue = [NSMutableArray arrayWithArray:addArray];
        }
    }
    
    if (queue || addArray)
    {
        if ([NSKeyedArchiver archiveRootObject:queue toFile:path])
        {
            NSLog(@"Queue updated successfully");
        }
        else
        {
            NSLog(@"Queue update failed");
        }
    }
    
    return queue;
}

- (NSDictionary *)writeDictionary:(NSDictionary *)dictionary toQueue:(NSString *)dictionaryName
{
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [paths stringByAppendingPathComponent:@"AmbassadorDocuments"];
    path = [path stringByAppendingPathComponent:dictionaryName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"Dictionary file found");
    }
    else
    {
        NSLog(@"Dictionary file not found");
    }
    
    if (dictionary)
    {
        if ([NSKeyedArchiver archiveRootObject:dictionary toFile:path])
        {
            NSLog(@"Dictionary updated successfully");
        }
        else
        {
            NSLog(@"Dictionry update failed");
        }
    }
    
    return dictionary;
}

- (NSMutableArray*)wipeArrayAtPath:(NSString *)queueName
{
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [paths stringByAppendingPathComponent:@"AmbassadorDocuments"];
    path = [path stringByAppendingPathComponent:queueName];
    NSMutableArray *queue;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"Queue file found");
        queue = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [queue removeAllObjects];
    }
    else
    {
        NSLog(@"Queue file not found");
    }
    
    if (queue)
    {
        if ([NSKeyedArchiver archiveRootObject:queue toFile:path])
        {
            NSLog(@"Queue wiped successfully");
        }
        else
        {
            NSLog(@"Queue wipe failed");
        }
    }
    
    return queue;
}

@end
