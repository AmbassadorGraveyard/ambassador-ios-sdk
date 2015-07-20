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
#import "RAFNavigationController.h"
#import "RAFShareScreen.h"



#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -



@implementation Ambassador

#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
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
        DLog(@"Removing user defaults for testing");
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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
    // Validate campaign ID before RAF is presented
    NSString *shortCodeURL = @"";
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
            }
        }
    }
    
    if ([shortCodeURL isEqualToString:@""])
    {
        NSLog(@"USER DOES NOT HAVE A SHORT CODE FOR THE GIVEN CAMPAIGN");
    }
    
    // Initialize root view controller
    RAFShareScreen *vc = [[RAFShareScreen alloc] initWithShortURL:shortCodeURL];
    
    // Initialize navigation controller and set vc as root
    RAFNavigationController *navController = [[RAFNavigationController alloc] initWithRootViewController:vc];
    navController.navigationBar.translucent = NO;
    navController.navigationBar.tintColor = AMB_NAVIGATION_BAR_TINT_COLOR();
    
    // Present
    [viewController presentViewController:navController animated:YES completion:nil];
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
