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
#import "EventObject.h"
#import "CutomTabBarController.h"
#import "TestWelcomeViewController.h"
#import "ConversionQueue.h"
//TODO: Import the view controllers

@implementation Ambassador

#pragma mark - Static class variables
static ConversionQueue *conversionQueue;
static NSTimer* timer;
static Identify *identify;
static NSString *APIKey;
static NSMutableDictionary *preferences;
static bool showWelcomeScreen = false;
static NSMutableDictionary *identifyData;
//TODO: add the view controllers


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


#pragma mark - Class method wrappers of instance methods
+ (void)runWithAPIKey:(NSString *)key
{
    [[Ambassador sharedInstance] runWithAPIKey:key];
}


+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    [[Ambassador sharedInstance] presentRAFFromViewController:viewController];
}

+ (void)registerConversionWithEmail:(NSString *)email
{
    [[Ambassador sharedInstance] registerConversionWithEmail:email];
}


#pragma mark - Internal API functions
- (void)runWithAPIKey:(NSString *)key
{
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeConversionCall) userInfo:nil repeats:YES];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY])
    {
        //We have identify
        NSLog(@"identify data found");
    }
    else
    {
        //We dont' have identify
        showWelcomeScreen = true;
        NSLog(@"identify not found");
    }

    APIKey = key;
    identify = [[Identify alloc] init];
    identifyData = [[NSMutableDictionary alloc] init];
    conversionQueue = [[ConversionQueue alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identifyCallback:)
                                                 name:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
                                               object:nil];
    
    [identify identify];
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    if (preferences && preferences.count > 0)
    {
        CutomTabBarController* vc = [[CutomTabBarController alloc] initWithUIPreferences:preferences];
        [viewController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)registerConversionWithEmail:(NSString *)email
{
    [conversionQueue registerConversionWithEmail:email];
}



#pragma mark - Helper functions
- (void)makeConversionCall
{
    [conversionQueue makeConversionCall];
}


- (void)identifyCallback:(NSNotification *)notification
{
    [self getPreferences];
    Identify* identificationObject = (Identify *)notification.object;
    identifyData = identificationObject.identifyData;
    if (conversionQueue.dirtyQueue) {
        [conversionQueue makeConversionCall];
    }
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
        
        [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:AMBASSADOR_USER_DEFAULTS_UIPREFERENCES_KEY];
        preferences = jsonData;
        
        if (showWelcomeScreen) {
            [self presentWelcomeScreenFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        
    }] resume];
}

- (void)presentWelcomeScreenFromViewController:(UIViewController *)viewController
{
    if (preferences && preferences.count > 0)
    {
        TestWelcomeViewController* vc = [[TestWelcomeViewController alloc] initWithPreferences:preferences];
        [viewController presentViewController:vc animated:YES completion:nil];
    }
}

@end
