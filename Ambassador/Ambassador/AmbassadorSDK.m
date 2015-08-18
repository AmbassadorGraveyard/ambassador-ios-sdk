//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "Constants.h"
#import "Identify.h"
#import "Conversion.h"
#import "ConversionParameters.h"
#import "Utilities.h"
#import "ServiceSelector.h"
#import "ServiceSelectorPreferences.h"



#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -

@interface AmbassadorSDK () <IdentifyDelegate>

@end


@implementation AmbassadorSDK

#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
static NSTimer *conversionTimer;
static Identify *identify;
static Conversion *conversion;
static ServiceSelector *raf;



#pragma mark - Object lifecycle
+ (AmbassadorSDK *)sharedInstance
{
    DLog();
    static AmbassadorSDK* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AmbassadorSDK alloc] init];
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
+ (void)runWithKey:(NSString *)key
{
    DLog();
    [[AmbassadorSDK sharedInstance] runWithKey:key
                              convertOnInstall:nil];
}

+ (void)runWithKey:(NSString *)key convertOnInstall:(ConversionParameters *)information
{
    DLog();
    [[AmbassadorSDK sharedInstance] runWithKey:key
                         convertOnInstall:information];
}

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController WithRAFParameters:(ServiceSelectorPreferences*)parameters
{
    DLog();
    if (!parameters) {
        parameters = [[ServiceSelectorPreferences alloc] init];
    }
    
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController withRAFParameters:parameters];
}

+ (void)registerConversion:(ConversionParameters *)information
{
    DLog();
    [[AmbassadorSDK sharedInstance] registerConversion:information];
}

+ (void)identifyWithEmail:(NSString *)email
{
    DLog();
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email];
}



#pragma mark - Internal API methods
- (void)runWithKey:(NSString *)key convertOnInstall:(ConversionParameters *)information
{
#if DEBUG
        DLog(@"Removing user defaults for testing");
//        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
    
    //Initialize class variables
    DLog(@"Initializing class variables");
    APIKey = key;
    conversionTimer = [NSTimer scheduledTimerWithTimeInterval:AMB_CONVERSION_FLUSH_TIME
                                                       target:self
                                                     selector:@selector(checkConversionQueue)
                                                     userInfo:nil
                                                      repeats:YES];
    identify = [[Identify alloc] initWithKey:APIKey];
    identify.delegate = self;
    conversion = [[Conversion alloc] initWithKey:APIKey];
    
    DLog(@"Checking if conversion is made on app launch");

    if (information)
    {
        // Check if this is the first time opening
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]) {
            DLog(@"\tSending conversion on app launch");
            [self registerConversion:information];
        }
    }
    
    // Set launch flag in User Deafaults
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY];

}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withRAFParameters:(ServiceSelectorPreferences*)parameters
{
    DLog();
    NSString *shortCodeURL = @"";
    NSString *shortCode = @"";
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
    if (userInfo)
    {
        NSArray* urls = userInfo[AMBASSADOR_INFO_URLS_KEY];
        for (NSDictionary *url in urls)
        {
            NSString *campaignID = [NSString stringWithFormat:@"%@", url[CAMPAIGN_UID_KEY]];
            if ([campaignID isEqualToString:ID])
            {
                shortCodeURL = url[SHORT_CODE_URL_KEY];
                shortCode = url[SHORT_CODE_KEY];
            }
        }
    }

    // Initialize root view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleWithIdentifier:@"com.Ambassador.Framework"]];
    UINavigationController *vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    raf = (ServiceSelector *)vc.childViewControllers[0];
    DLog(@"ShortCodeURL: %@    ShortCode: %@",shortCodeURL, shortCode);
    raf.shortCode = shortCode;
    raf.shortURL = shortCodeURL;
    parameters.textFieldText = shortCodeURL;
    raf.prefs = parameters;
    raf.APIKey = APIKey;
    raf.campaignID = ID;

    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)registerConversion:(ConversionParameters *)information
{
    DLog();
    [conversion registerConversionWithParameters:information];
}

- (void)identifyWithEmail:(NSString *)email
{
    DLog();
    [identify identifyWithEmail:email];
}



#pragma mark - Helper functions
- (void)checkConversionQueue
{
    DLog();
    [conversion sendConversions];
}



#pragma mark - Identify Delegate
- (void)ambassadorDataWasRecieved:(NSMutableDictionary *)data
{
    NSString *shortCodeURL = @"";
    NSString *shortCode = @"";
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
    if (userInfo)
    {
        NSArray* urls = userInfo[AMBASSADOR_INFO_URLS_KEY];
        for (NSDictionary *url in urls)
        {
            NSString *campaignID = [NSString stringWithFormat:@"%@", url[CAMPAIGN_UID_KEY]];
            if ([campaignID isEqualToString:raf.campaignID])
            {
                shortCodeURL = url[SHORT_CODE_URL_KEY];
                shortCode = url[SHORT_CODE_KEY];
            }
        }
    }
    raf.shortCode = shortCode;
    raf.shortURL = shortCodeURL;
    
    [raf removeWaitView];
}

@end
