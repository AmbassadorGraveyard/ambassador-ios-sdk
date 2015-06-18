//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Ambassador.h"

@implementation Ambassador

#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
static NSMutableDictionary *identifyData;
static bool showWelcomeScreen = false;
//TODO: add objects once created
//  * identify
//  * conversion



#pragma mark - Object lifecycle
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

#pragma mark - Class API method wrappers of instance API methods
//This was done to allow [Ambassador some_method]
//                                  vs
//                 [[Ambassador sharedInstance] some_method]
//
+ (void)runWithAPIKey:(NSString *)key
{

}

+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    
}

+ (void)registerConversionWithEmail:(NSString *)email
{
    
}

/*
#pragma mark - Internal API methods
- (void)runWithAPIKey:(NSString *)key
{
    //
    // Set up timer to check for conversions that didn't get sent successfully
    //
    
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
 */



@end
