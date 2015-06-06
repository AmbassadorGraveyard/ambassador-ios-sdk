//
//  ConversionQueue.m
//  iOSSDKtest
//
//  Created by Diplomat on 6/5/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ConversionQueue.h"
#import "Constants.h"
#import "EventObject.h"

@implementation ConversionQueue

- (id)init
{
    if ([super init]) {
        if ([self getConversionQueue].count > 0) {
            self.dirtyQueue = YES;
        }
    }
    return self;
}

- (void)addToConversionQueue:(NSData *)event
{
    self.dirtyQueue = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Add to conversion queue called");
        NSMutableArray *queue;
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"conversion.queue"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            queue = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        }
        else
        {
            queue = [[NSMutableArray alloc] init];
        }
        
        [queue addObject:event];
        
        NSLog(@"%ld", (unsigned long)queue.count);
        
        if ([queue writeToFile:filePath atomically:YES])
        {
            NSLog(@"Queue updated");
        }
        else
        {
            NSLog(@"Queue failed");
        }
    });
}

- (NSMutableArray *)getConversionQueue
{
    NSMutableArray *queue;
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"conversion.queue"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        queue = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }
    else
    {
        queue = [[NSMutableArray alloc] init];
    }
    return queue;
}

- (void)registerConversionWithEmail:(NSString *)email
{
    //TODO: Check the install date of the app
    //    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
    //                                                                          inDomains:NSUserDomainMask] lastObject];
    //    __autoreleasing NSError *error;
    //    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path
    //                                                                            error:&error] objectForKey:NSFileCreationDate];
    //    NSLog(@"App installed on %@", installDate);
    //
    
    EventObject *obj = [[EventObject alloc] init];
    obj.parameter = @"name";
    
    [self addToConversionQueue:[NSKeyedArchiver archivedDataWithRootObject:obj]];
    [self makeConversionCall];
}

- (void)makeConversionCall
{
    NSMutableArray * conversionQueue = [self getConversionQueue]; //USe this in request
    
    if (!self.dirtyQueue) {
        NSLog(@"dirty queue is emtpy");
        return;
    }
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/register"]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (error) { return; }
          
          NSLog(@"Conversion sent successfully");
          [self emptyQueue];
      }] resume];
}

- (void)emptyQueue
{
    self.dirtyQueue = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *queue;
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"conversion.queue"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            queue = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        }
        else
        {
            queue = [[NSMutableArray alloc] init];
        }
        
        if (queue.count > 0) {
            [queue removeAllObjects];
            
            NSLog(@"%ld", (unsigned long)queue.count);
            
            if ([queue writeToFile:filePath atomically:YES])
            {
                NSLog(@"Queue updated");
            }
            else
            {
                NSLog(@"Queue failed");
            }
        }
    });
}

@end
