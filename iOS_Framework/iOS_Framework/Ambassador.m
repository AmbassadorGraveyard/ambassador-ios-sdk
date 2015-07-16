//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Ambassador.h"
#import "Constants.h"
#import "Identify.h"
#import "Conversion.h"
#import "ConversionParameters.h"
#import "Utilities.h"



#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;



@implementation Ambassador
#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
static bool showWelcomeScreen = false;
static NSTimer *conversionTimer;
static Identify *identify;
static Conversion *conversion;



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
+ (void)runWithKey:(NSString *)key convertingOnLaunch:(ConversionParameters *)information
{
    DLog();
    [[Ambassador sharedInstance] runWithKey:key
                         convertingOnLaunch:information];
}

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController
{
    DLog();
    [[Ambassador sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
}

+ (void)registerConversion:(ConversionParameters *)information
{
    DLog();
    [[Ambassador sharedInstance] registerConversion:information];
}

+ (void)identifyWithEmail:(NSString *)email
{
    DLog();
    [[Ambassador sharedInstance] identifyWithEmail:email];
}



#pragma mark - Internal API methods
- (void)runWithKey:(NSString *)key convertingOnLaunch:(ConversionParameters *)information
{
#if DEBUG
    //    DLog(@"Removing user defaults for testing");
    //    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
    
    //Check if we have identify data. If not, the welcome may need to be shown
    //Could be set to no if not refered, the app was reinstalled but backend has
    //device id, etc.
    DLog(@"Checking for identify data");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_USER_DEFAULTS_KEY])
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
    conversionTimer = [NSTimer scheduledTimerWithTimeInterval:AMB_CONVERSION_FLUSH_TIME
                                                       target:self
                                                     selector:@selector(checkConversionQueue)
                                                     userInfo:nil
                                                      repeats:YES];
    identify = [[Identify alloc] init];
    conversion = [[Conversion alloc] init];
    //[identify identifyWithEmail:@""];
    DLog(@"Checking if conversion is made on app launch");
    if (information)
    {
        DLog(@"\tSending conversion on app launch");
        [self registerConversion:information];
    }
}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController
{
    DLog();
    NSDictionary *ambassadorInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_STORAGE_KEY];
    NSArray *urls = ambassadorInfo[@"urls"];
    
    for (NSDictionary* url in urls)
    {
        NSString *campaignUID = [NSString stringWithFormat:@"%@", url[@"campaign_uid"]];
        
        if ([campaignUID isEqualToString:ID])
        {
            DLog(@"%@", url[@"url"]);
        }
    }
    
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

@end
