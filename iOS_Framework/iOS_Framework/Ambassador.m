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
#import "ServiceSelector.h"
#import "ServiceSelectorPreferences.h"




#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
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
+ (void)runWithKey:(NSString *)key convertOnInstall:(ConversionParameters *)information
{
    DLog();
    [[Ambassador sharedInstance] runWithKey:key
                         convertOnInstall:information];
}

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController WithRAFParameters:(ServiceSelectorPreferences*)parameters
{
    DLog();
    if (!parameters) {
        parameters = [[ServiceSelectorPreferences alloc] init];
    }
    
    [[Ambassador sharedInstance] presentRAFForCampaign:ID FromViewController:viewController withRAFParameters:parameters];
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
    conversion = [[Conversion alloc] initWithKey:APIKey];
    
    DLog(@"Checking if conversion is made on app launch");

    if (information)
    {
        // Check if this is the first time opening
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]) {
            NSLog(@"\tSending conversion on app launch");
            [self registerConversion:information];
        }
    }
    
    // Set launch flag in User Deafaults
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY];

}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withRAFParameters:(ServiceSelectorPreferences*)parameters
{
    DLog();
    // Validate campaign ID before RAF is presented
    
    //TODO: take this out after daisy chain
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
    
    if ([shortCodeURL isEqualToString:@""])
    {
        NSLog(@"USER DOES NOT HAVE A SHORT CODE FOR THE GIVEN CAMPAIGN");
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Network Error"
                                    message:@"We couldn't load your URLs. Check your network connection and try again"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"Ok"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       //[self.presentingViewController dismissViewControllerAnimated:YES
                                       // completion:nil];
                                   }];
        
        [alert addAction:okAction];
        
        [viewController presentViewController:alert animated:YES completion:nil];
        //TODO: try to grab the short codes again
        
    }
    
    // Initialize root view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleWithIdentifier:@"com.ambassador.Framework"]];
    UINavigationController *vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    ServiceSelector *rootVC = (ServiceSelector *)vc.childViewControllers[0];
    
    //TODO: set short code and text field text
    rootVC.shortCode = shortCode;
    rootVC.shortURL = shortCodeURL;
    parameters.textFieldText = shortCodeURL;
    rootVC.prefs = parameters;
    rootVC.APIKey = APIKey;

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



@end
