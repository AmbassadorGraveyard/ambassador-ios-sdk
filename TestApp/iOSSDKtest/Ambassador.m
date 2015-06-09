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
#import "Conversion.h"
//TODO: Import the view controllers

@implementation Ambassador

#pragma mark - Static class variables
static Conversion *conversionQueue;
static Identify *identify;
static NSTimer* timer;
static NSString *APIKey;
static NSMutableDictionary *preferences;
static NSMutableDictionary *identifyData;
static bool showWelcomeScreen = false;
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
    NSLog(@"in class call");
    //TODO:fix what actually needs to be put here
    [conversionQueue push:email];
}


#pragma mark - Internal API functions
- (void)runWithAPIKey:(NSString *)key
{
    //
    // Set up timer to check for conversions that didn't get sent successfully
    //
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeNetworkCall) userInfo:nil repeats:YES];
    
    //
    // Listen for successful call to identify (we got a fingerprint back)
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identifyCallback:) name:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION object:nil];
    
    //
    // TODO: Remove for production
    //
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //
    // Check if we have identify data. If not, the welcome screen should be shown
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY])
    {
        NSLog(@"identify data found");
    }
    else
    {
        showWelcomeScreen = true;
        NSLog(@"identify not found");
    }

    APIKey = key;
    identify = [[Identify alloc] init];
    identifyData = [[NSMutableDictionary alloc] init];
    conversionQueue = [[Conversion alloc] init];
    [identify identify];
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    if (preferences && preferences.count > 0)
    {
        CutomTabBarController* vc = [[CutomTabBarController alloc] initWithUIPreferences:preferences andSender:self];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else
        {
            vc.modalPresentationStyle = UIModalPresentationPageSheet;
        }

        //[vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [viewController presentViewController:vc animated:YES completion:nil];
    }
}


#pragma mark - Helper functions
- (void)makeNetworkCall
{
    [conversionQueue makeNetworkCall];
}

- (void)identifyCallback:(NSNotification *)notification
{
    //
    // Get preferences
    //
    [self getUIPreferences];
    
    Identify* identificationObject = (Identify *)notification.object;
    identifyData = identificationObject.identifyData;
    [conversionQueue makeNetworkCall];
    
}

-(void)getUIPreferences
{
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:AMBASSADOR_PREFERENCE_URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(AMBASSADOR_NETWORK_UNREACHABLE_ERROR, error);
            return;
        }
        
        __autoreleasing NSError *e;
        NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        
        if (e)
        {
            NSLog(@"%@\n%@", AMBASSADOR_JSON_PARSE_ERROR, e);
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:AMBASSADOR_USER_DEFAULTS_UIPREFERENCES_KEY];
        preferences = jsonData;

//                                                                                            //
//TODO: set the welcome screen from api response to see if identify has been registered before//
//                                                                                            //
        
        if (showWelcomeScreen)
        {
            [self presentWelcomeScreenFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        
    }] resume];
}

- (void)presentWelcomeScreenFromViewController:(UIViewController *)viewController
{
    if (preferences && preferences.count > 0)
    {
        TestWelcomeViewController* vc = [[TestWelcomeViewController alloc] initWithPreferences:preferences];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else
        {
            vc.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [viewController presentViewController:vc animated:YES completion:nil];
    }
}

@end
