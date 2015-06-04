//
//  EventQueue.m
//  test
//
//  Created by Diplomat on 6/4/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "EventQueue.h"

@interface EventQueue ()

@property NSMutableArray *queue;
@property NSString *rootPath;
@property NSString *localPath;
@property NSString *queueName;
@property BOOL directoryIsSet;
@property BOOL fileIsSet;

@end

@implementation EventQueue

- (id)initWithQueueName:(NSString *)queueName
{
    if ([super init]) {
        self.rootPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"AmbassadorDocuments"];
        self.queueName = queueName;
        
        __autoreleasing NSError *e;
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.rootPath])
        {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.rootPath withIntermediateDirectories:NO attributes:nil error:&e])
            {
                NSLog(@"Error creating AmbassadorDocuments directory");
                self.directoryIsSet = NO;
            }
            else
            {
                NSLog(@"Created AmbassadorDocuments directory");
                self.directoryIsSet = YES;
            }
        }
        else
        {
            NSLog(@"AmbassadorDocuments directory found");
            self.directoryIsSet = YES;
        }
        
        if (self.directoryIsSet)
        {
            self.localPath = [self.rootPath stringByAppendingPathComponent:queueName];
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.localPath])
            {
                NSMutableArray * queue = [NSMutableArray arrayWithArray:@[]];
                if ([NSKeyedArchiver archiveRootObject:queue toFile:self.localPath])
                {
                    NSLog(@"Queue in %@ created", queueName);
                    self.fileIsSet = YES;
                }
                else
                {
                    NSLog(@"Queue could not be created in %@", queueName);
                    self.fileIsSet = NO;
                }
            }
            else
            {
                NSLog(@"%@ found", queueName);
                self.fileIsSet = YES;
            }
        }
    }
    
    return self;
}

- (BOOL)pushEvent:(EventObject *)event
{
    if (!(self.directoryIsSet && self.fileIsSet)) { return NO; }
    
    NSMutableArray *queue = [NSKeyedUnarchiver unarchiveObjectWithFile:self.localPath];
    if (queue)
    {
        [queue addObject:event];
        if ([NSKeyedArchiver archiveRootObject:queue toFile:self.localPath])
        {
            NSLog(@"Queue in file %@ updated", self.queueName);
            return YES;
        }
        else{
            NSLog(@"Queue in file %@ couldn't be updated", self.queueName);
            return NO;
        }
    }
    else
    {
        NSLog(@"Queue in file %@ could not be read", self.queueName);
        return NO;
    }
}

- (BOOL)emptyQueue
{
    if (!(self.directoryIsSet && self.fileIsSet)) { return NO; }
    
    NSMutableArray *queue = [NSKeyedUnarchiver unarchiveObjectWithFile:self.localPath];
    if (queue)
    {
        [queue removeAllObjects];
        if ([NSKeyedArchiver archiveRootObject:queue toFile:self.localPath])
        {
            NSLog(@"Queue in file %@ emptied", self.queueName);
            return YES;
        }
        else{
            NSLog(@"Queue in file %@ couldn't be emptied", self.queueName);
            return NO;
        }
    }
    else
    {
        NSLog(@"Queue in file %@ could not be read", self.queueName);
        return NO;
    }


}

- (NSMutableArray *)getQueue
{
    if (!(self.directoryIsSet && self.fileIsSet)) { return nil; }
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.localPath];
}

@end
