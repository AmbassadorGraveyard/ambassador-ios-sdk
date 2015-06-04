//
//  Ambassador.m
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Constants.h"
#import "Ambassador.h"
#import "Identify.h"
#import "EventQueue.h"
#import "CutomTabBarController.h"
#import "TestWelcomeViewController.h"
#import "interface.h"
//TODO: Import the view controllers


@implementation Ambassador

#pragma mark - Singleton instantiation
+ (Ambassador *)sharedInstance
{
    static Ambassador* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[Ambassador alloc] init];
    });
    
    return _sharedInsance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Static class variables
static Identify *identify;
static EventQueue *eventsQueue;
static NSString *APIKey;
static NSMutableDictionary *preferences;
static bool showWelcomeScreen = false;
static NSMutableDictionary *identifyData;
//TODO: add the view controllers


#pragma mark - Class method wrappers of instance methods
+ (void)runWithAPIKey:(NSString *)key
{
    [[Ambassador sharedInstance] runWithAPIKey:key];
}

+ (void)registerConversionWithEmail:(NSString *)email
{
    [[Ambassador sharedInstance] registerConversionWithEmail:email];
}

+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    [[Ambassador sharedInstance] presentRAFFromViewController:viewController];
}


#pragma mark - Internal API functions
- (void)runWithAPIKey:(NSString *)key
{
    interface *fileInterface = [[interface alloc] init];
    NSString *path = [fileInterface getPathDirectory];
    [path stringByAppendingPathComponent:@"identify.data"];
    
    
    //TODO: REMOVE THESE FOR PRODUCTION
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //TODO: API key set
        showWelcomeScreen = true;
    }
    
    
    
    NSLog(@"identify.data found");
    APIKey = key;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identifyCallback:)
                                                 name:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
                                               object:nil];
    
    identify = [[Identify alloc] init];
    eventsQueue = [[EventQueue alloc] initWithQueueName:@"events.queue"];
    identifyData = [[NSMutableDictionary alloc] init];
    [identify identify];
    
}

- (void)identifyCallback:(NSNotification *)notification
{
    [self getPreferences];
    Identify* identificationObject = (Identify *)notification.object;
    identifyData = identificationObject.identifyData;
    [self emptyQueue];
}

-(void)getPreferences
{
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:AMBASSADOR_PREFERENCE_URL]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(AMBASSADOR_NETWORK_UNREACHABLE_ERROR, error);
            return;
        }
        
        __autoreleasing NSError *e;
        NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&e];
        if (e)
        {
            NSLog(@"%@\n%@", AMBASSADOR_JSON_PARSE_ERROR, e);
            return;
        }
        
        interface *fileInterface = [[interface alloc] init];
        if ([fileInterface setUpAmbassadorDocumentsDirectory]) {
            NSLog(@"%@", [fileInterface writeDictionary:jsonData toQueue:@"ui.preferences"]);
        }
        
        preferences = jsonData;
        
        if (showWelcomeScreen) {
            [self presentWelcomeScreenFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        
    }] resume];

}

- (void)registerConversionWithEmail:(NSString *)email
{
    EventObject *event = [[EventObject alloc] init];
    event.parameter = email;
    [eventsQueue pushEvent:event];
    NSLog(@"%@", [eventsQueue getQueue]);
}

- (void)presentWelcomeScreenFromViewController:(UIViewController *)viewController
{
    TestWelcomeViewController* vc = [[TestWelcomeViewController alloc] initWithPreferences:preferences];
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    CutomTabBarController* vc = [[CutomTabBarController alloc] initWithUIPreferences:preferences];
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)emptyQueue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __autoreleasing NSError *e;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:identifyData options:0 error:&e];
        
        if (e) {
            NSLog(@"Couldn't parse JSON");
            return;
        }
        
        NSURL *url = [NSURL URLWithString:AMBASSADOR_IDENTIFY_URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request setHTTPMethod:@"PSOT"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                //if (error) {
               //     NSLog(@"Couldn't send queue");
              //  }
                NSLog(@"Successfully sent queue");
                [eventsQueue emptyQueue];
            //}];
        });
    });
}

@end
