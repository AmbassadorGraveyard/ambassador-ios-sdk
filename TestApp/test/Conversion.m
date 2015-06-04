//
//  Conversion.m
//  test
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Conversion.h"
#import "Constants.h"
#import "interface.h"

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
    interface *fileInterface = [[interface alloc] init];
    NSString *path = [fileInterface getPathDirectory];
    path = [path stringByAppendingPathComponent:@"identify.data"];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"Identify data not found");

        if ([fileInterface setUpAmbassadorDocumentsDirectory])
        {
            NSLog(@"Queue size: %ld items",[fileInterface writeArray:@[@YES] toQueue:@"events.queue"].count);
        }
        return NO;
    }
    
    if ([email isEqualToString:@""])
    {
        //TODO: Handle situation when email is not passed
        [self makeAPICallWithEmail:email];
    }
    else
    {
        //TODO: Handle situation when email is passed
        [self makeAPICallWithEmail:email];
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
              NSLog(@"Couldn't make API conversion call");
              interface *fileInterface = [[interface alloc] init];
              if ([fileInterface setUpAmbassadorDocumentsDirectory])
              {
                  NSLog(@"Queue size: %ld items", [fileInterface writeArray:@[@YES] toQueue:@"events.queue"].count);
              }
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
    NSLog(@"Attempting to flush queue...");
    interface *fileInterface = [[interface alloc] init];
    NSMutableArray *queue;
    if ([fileInterface setUpAmbassadorDocumentsDirectory])
    {
        queue = [fileInterface writeArray:nil toQueue:@"events.queue"];
    }
    
    if (queue && queue.count> 0)
    {
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:@""]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              if (error)
              {
                  NSLog(@"Couldn't make API conversion call");
                  interface *fileInterface = [[interface alloc] init];
                  if ([fileInterface setUpAmbassadorDocumentsDirectory])
                  {
                      NSLog(@"Queue size: %ld items", [fileInterface writeArray:@[@YES] toQueue:@"events.queue"].count);
                  }
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
}

@end
