//
//  Conversion.m
//  iOSSDKtest
//
//  Created by Diplomat on 6/9/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Conversion.h"
#import "Constants.h"

@interface Conversion ()

@property NSString *documentPath;
@property NSString *filePath;

@end


@implementation Conversion

- (id)init
{
    if ([super init])
    {
        self.queue = [[NSMutableArray alloc] init];
        self.documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.filePath = [self.documentPath stringByAppendingPathComponent:@"conversion.queue"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
        {
            self.queue = [[NSMutableArray alloc] initWithContentsOfFile:self.filePath];
        }
        else
        {
            self.queue = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)push:(id)object
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.queue addObject:object];
    [self writeToDisk];
}

- (id)pop
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    id object = [self.queue lastObject];
    [self.queue removeLastObject];
    [self writeToDisk];
    return object;
}

- (void)empty
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.queue removeAllObjects];
    [self writeToDisk];
}

- (void)writeToDisk
{
    [self printQueue];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.queue writeToFile:self.filePath atomically:YES];
}

- (void)makeNetworkCall
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!self.queue.count > 0) { NSLog(@"Queue is emtpy"); return; }
    
    //Send the conversion if we have identify data to send with it
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY]) {
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/register"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              if (error) { return; }
              NSLog(@"Conversion sent successfully");
              dispatch_async(dispatch_get_main_queue(), ^{ [self empty]; });
          }
        ] resume];
    }
    else
    {
        NSLog(@"Waiting on identify data to send conversion");
    }
}

- (void)printQueue
{
    NSLog(@"\nQueue: %@", self.queue);
}

@end
