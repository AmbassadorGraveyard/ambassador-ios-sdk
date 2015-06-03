//
//  Conversion.m
//  test
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Conversion.h"
#import "Constants.h"

@interface Conversion ()

@end


@implementation Conversion

#pragma mark - Inits & Dealloc
- (id)init
{
    if ([super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flushQueue)
                                                     name:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - API Functions
- (BOOL)registerConversion
{
    return [self registerConversionWithEmail:@""];
}

- (BOOL)registerConversionWithEmail:(NSString *)email
{
    //TODO: Check the install date of the app
    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] lastObject];
    __autoreleasing NSError *error;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path
                                                                            error:&error] objectForKey:NSFileCreationDate];
    NSLog(@"App installed on %@", installDate);
    
    //Check if we have identify
    if (! [[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY])
    {
        NSLog(@"Identify data not found");
        NSMutableArray * queue = [[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_EVENT_QUEUE_KEY];
        if (!queue) {
            queue = [[NSMutableArray alloc] init];
            NSLog(@"Events queue created");
        } else {
            NSLog(@"Events queue appended");
        }
        [queue addObject:@YES];
        [[NSUserDefaults standardUserDefaults] setObject:queue forKey:AMBASSADOR_USER_DEFAULTS_EVENT_QUEUE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([email isEqualToString:@""])
    {
        //TODO: Handle situation when email is not passed
        //[self makeAPICallWithEmail:email];
    }
    else
    {
        //TODO: Handle situation when email is passed
        //[self makeAPICallWithEmail:email];
    }
    return YES;
}


#pragma mark - Helper Functions
- (void)makeAPICallWithEmail:(NSString*)email
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@""]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
              NSLog(@"Couldn't make API conversion call\n%@", error);
              return;
          }
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          if (httpResponse.statusCode == 200)
          {
              //TODO: Do something with successful call
          }
          else
          {
              //TODO: Do something with unsuccessful call
          }
      }] resume];
}

- (void)flushQueue
{
    NSMutableArray * queue = [[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_EVENT_QUEUE_KEY];
    if (queue)
    {
        if (queue.count > 0)
        {
            queue = (NSMutableArray *)queue;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [queue removeAllObjects];
                [[NSUserDefaults standardUserDefaults] setObject:queue forKey:AMBASSADOR_USER_DEFAULTS_EVENT_QUEUE_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"Event queue flushed");
            });
        }
        //We don't have to worry if the queue is empty
    }
    else
    {
        NSLog(@"Event queue didnt exist");
    }
   
    //We don't have to worry if there isn't even a queue made
}

@end
