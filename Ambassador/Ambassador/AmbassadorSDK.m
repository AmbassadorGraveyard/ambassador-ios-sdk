//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "AMBConstants.h"
#import "AMBIdentify.h"
#import "AMBConversion.h"
#import "AMBConversionParameters.h"
#import "AMBUtilities.h"
#import "AMBServiceSelector.h"
#import "AMBServiceSelectorPreferences.h"
#import "AMBThemeManager.h"



#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -

@interface AmbassadorSDK () <AMBIdentifyDelegate>

@end


@implementation AmbassadorSDK

#pragma mark - Static class variables
static NSString *AMBuniversalToken;
static NSString *AMBuniversalID;
static NSMutableDictionary *backEndData;
static NSTimer *conversionTimer;
static AMBIdentify *identify;
static AMBConversion *conversion;
static AMBServiceSelector *raf;



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
+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID
{
    DLog();
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:nil completion:nil];
}

+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion
{
    DLog();
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:information completion:completion];
}

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController
{
    DLog();
    
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
}

+ (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion
{
    DLog();
    [[AmbassadorSDK sharedInstance] registerConversion:information completion:completion];
}

+ (void)identifyWithEmail:(NSString *)email
{
    DLog();
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email];
}



#pragma mark - Internal API methods
- (void)runWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion
{
#if DEBUG
        DLog(@"Removing user defaults for testing");
//        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
    
    //Initialize class variables
    DLog(@"Initializing class variables");
    AMBuniversalID = universalID;
    AMBuniversalToken = universalToken;
    conversionTimer = [NSTimer scheduledTimerWithTimeInterval:AMB_CONVERSION_FLUSH_TIME
                                                       target:self
                                                     selector:@selector(checkConversionQueue)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [[NSUserDefaults standardUserDefaults] setValue:universalToken forKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:universalID forKey:AMB_UNIVERSAL_ID_DEFAULTS_KEY];
    identify = [[AMBIdentify alloc] initForFullIdentify];
    identify.delegate = self;
    conversion = [[AMBConversion alloc] initWithKey:universalToken];
    
    DLog(@"Checking if conversion is made on app launch");

    if (information)
    {
        // Check if this is the first time opening
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]) {
            DLog(@"\tSending conversion on app launch");
            [self registerConversion:information completion:completion];
        }
    }
    
    // Set launch flag in User Deafaults
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY];

}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController
{
    DLog();
    NSString *shortCodeURL = @"";
    NSString *shortCode = @"";
    [[NSUserDefaults standardUserDefaults] setValue:ID forKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY];
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
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    UINavigationController *vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    raf = (AMBServiceSelector *)vc.childViewControllers[0];
    DLog(@"ShortCodeURL: %@    ShortCode: %@", shortCodeURL, shortCode);
    raf.shortCode = shortCode;
    raf.shortURL = shortCodeURL;
    
    AMBServiceSelectorPreferences *prefs = [[AMBServiceSelectorPreferences alloc] init];
    prefs.titleLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFWelcomeTextMessage];
    prefs.descriptionLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFDescriptionTextMessage];
    prefs.defaultShareMessage = [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage];
    prefs.navBarTitle = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    prefs.textFieldText = shortCodeURL;
    raf.prefs = prefs;
    raf.APIKey = AMBuniversalToken;
    raf.campaignID = ID;

    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion
{
    DLog();
    [conversion registerConversionWithParameters:information completion:completion];
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
