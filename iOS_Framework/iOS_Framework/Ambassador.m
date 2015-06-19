//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Ambassador.h"
#import "Constants.h"

@implementation Ambassador

#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
static NSMutableDictionary *identifyData;
static bool showWelcomeScreen = false;
static NSTimer *conversionTimer;
//TODO: add objects once created
//  * identify
//  * conversion



#pragma mark - Object lifecycle
+ (Ambassador *)sharedInstance
{
    DLog();
    static Ambassador* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[Ambassador alloc] init];
    });
    
    return _sharedInsance;
}

- (void)dealloc
{
    DLog();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Class API method wrappers of instance API methods
//This was done to allow [Ambassador some_method]
//                                  vs
//                 [[Ambassador sharedInstance] some_method]
//
+ (void)runWithKey:(NSString *)key convertingOnLaunch:(NSDictionary *)information
{
    DLog();
    [[Ambassador sharedInstance] runWithKey:key
                      convertingOnLaunch:information];
}

+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    DLog();
    [[Ambassador sharedInstance] presentRAFFromViewController:viewController];
}

+ (void)registerConversion:(NSDictionary *)information
{
    DLog();
    [[Ambassador sharedInstance] registerConversion:information];
}


#pragma mark - Internal API methods
- (void)runWithKey:(NSString *)key convertingOnLaunch:(NSDictionary *)information
{
    DLog();
    DLog(@"Begin listening for identify notification")
    //Listen for successful call to identify (we got a fingerprint back)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identifyCallback:)
                                                 name:AMB_IDENTIFY_NOTIFICATION_NAME
                                               object:nil];
    
    DLog(@"Removing user defaults for testing");
    // TODO: Remove for production
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    
    //
    //Check if we have identify data. If not, the welcome may need to be shown
    //Could be set to no if not refered, the app was reinstalled but backend has
    //device id, etc.
    //
    DLog(@"Checking for identify data");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_STORAGE_KEY])
    {
        DLog(@"\tIdentify data was found");
    }
    else
    {
        showWelcomeScreen = true;
        DLog(@"\tIdentify data not found");
    }
    
    //Initialize class variables
    DLog(@"Initializing class variables");
    APIKey = key;
    conversionTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                       target:self
                                                     selector:@selector(checkConversionQueue)
                                                     userInfo:nil
                                                      repeats:YES];
    //TODO: Initialize identify object
    //TODO: Initialize conversion object
    //TODO: Make call to identify
    DLog(@"Checking if conversion is made on app launch");
    if (information)
    {
        DLog(@"\tSending conversion on app lanuch");
        [self registerConversion:information];
    }
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    DLog();
}

- (void)registerConversion:(NSDictionary *)information
{
    DLog();
}




#pragma mark - Callback functions
- (void)identifyCallback:(NSNotification *)notifications
{
    DLog();
}



#pragma mark - Helper functions
- (void)checkConversionQueue
{
    DLog();
}

@end
