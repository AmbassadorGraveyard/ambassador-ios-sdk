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
                                                     name:JSONCompletedNotificationName
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
    return [self registerConversionWithEmail:noConversionEmailDefualtString];
}

- (BOOL)registerConversionWithEmail:(NSString *)email
{
    //TODO: Check the install date of the app
    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] lastObject];
    __autoreleasing NSError *error;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path
                                                                            error:&error] objectForKey:NSFileCreationDate];
    NSLog(@"This app was installed by the user on %@", installDate);
    
    //Check if we have identify
    if (! [[NSUserDefaults standardUserDefaults] dictionaryForKey:NSUserDefaultsKeyName])
    {
        NSLog(@"Identify data not found");
        
        //Create or add to queue
        NSMutableArray *queue = [[NSMutableArray alloc] init];
        [queue addObject:@YES];
        if (![[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Ambassaqueue"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:queue forKey:@"Ambassaqueue"];
            NSLog(@"Created queue");
        }
        else
        {
            queue = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"Ambassaqueue"];
            NSLog(@"Appended to queue");
        }
        //TODO: Add to queue
        [[NSUserDefaults standardUserDefaults] setObject:queue forKey:@"Ambassaqueue"];
    }
    
    if ([email isEqualToString:noConversionEmailDefualtString])
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
              NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Non 200 server response" };
              //TODO: Fix the code in the error
              NSLog(@"%@", [NSError errorWithDomain:conversionErrorDomain
                                               code:httpResponse.statusCode
                                           userInfo:userInfo]);
          }
      }] resume];
}

- (void)flushQueue
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Ambassaqueue"])
    {
        /*
            -------------------------------------------------------------------------
            TODO: Put this on a background queue. It can be called before preferences 
            get loaded, and so a delay here is going to indirectly block the 
            main thread and Ambassador viewController presentation
            -------------------------------------------------------------------------
        */
        NSMutableArray * queue = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"Ambassaqueue"];
        if (queue.count > 0)
        {
            //TODO: Flush queue
            NSLog(@"Queue flushed");
            [queue removeAllObjects];
        }
        //We don't have to worry if the queue is empty
    }
    //We don't have to worry if there isn't even a queue made
}

@end
