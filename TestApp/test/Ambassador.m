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
#import "Conversion.h"
#import "CutomTabBarController.h"
#import "TestWelcomeViewController.h"
//TODO: Import the view controllers


@implementation Ambassador

#pragma mark - Singleton instantiation
+ (Ambassador *)sharedInstance
{
    //TODO: REMOVE THESE FOR PRODUCTION
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    
    
    
    static Ambassador* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[Ambassador alloc] init];
    });
    
    return _sharedInsance;
}


#pragma mark - Static class variables
static Identify *identify;
static Conversion *conversion;
static NSString *APIKey;
static NSMutableDictionary *preferences;
static bool showWelcomeScreen = false;
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

+ (void)registerConversion
{
    [[Ambassador sharedInstance] registerConversion];
}

+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    [[Ambassador sharedInstance] presentRAFFromViewController:viewController];
}


#pragma mark - Internal API functions
- (void)runWithAPIKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* userDefaultsAPIKey = [defaults stringForKey:AMBASSADOR_USER_DEFAULTS_APIKEY_KEY];
    if (!userDefaultsAPIKey)
    {
        //TODO: API key set
        showWelcomeScreen = true;
    }
    [defaults setObject:key forKey:AMBASSADOR_USER_DEFAULTS_APIKEY_KEY];
    [defaults synchronize];
    APIKey = key;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPreferences)
                                                 name:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
                                               object:nil];
    
    identify = [[Identify alloc] init];
    conversion = [[Conversion alloc] init];
    [identify identify];
    
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
        NSLog(@"%@", AMBASSADOR_PREFERENCES_DATA_RECIEVED_SUCCESS);
        preferences = jsonData;
        
        if (showWelcomeScreen) {
            [self presentWelcomeScreenFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        
    }] resume];
}

- (void)registerConversion
{
    [conversion registerConversion];
}

- (void)registerConversionWithEmail:(NSString *)email
{
    [conversion registerConversionWithEmail:email];
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

@end
