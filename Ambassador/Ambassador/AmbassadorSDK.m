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
#import "AMBPusherManager.h"
#import "AMBAmbassadorNetworkManager.h"
#import "AMBNetworkObject.h"
#import "AMBPusher.h"


#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -

@interface AmbassadorSDK () //<AMBIdentifyDelegate>
@property AMBIdentify *identify;
@property AMBPusherManager *pusherManager;
@property AMBNetworkManager *ambassadorNetworkManager;
@property NSTimer *conversionTimer;
@property AMBConversion *conversion;

@property AMBUserNetworkObject *user;

@property NSString *email;
@property NSString *universalToken;
@property NSString *universalID;
@end


@implementation AmbassadorSDK

#pragma mark - Static class variables
static AMBServiceSelector *raf;



#pragma mark - Object lifecycle
+ (AmbassadorSDK *)sharedInstance {
    static AmbassadorSDK* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AmbassadorSDK alloc] init]; });
    return _sharedInsance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    if (self = [super init]) {
        self.identify = [[AMBIdentify alloc] init];
        self.ambassadorNetworkManager = [AMBAmbassadorNetworkManager sharedInstance];
        self.user = [AMBUserNetworkObject loadFromDisk];
    }
    return self;
}


#pragma mark - Class API method wrappers of instance API methods
//This was done to allow [Ambassador some_method]
//                                  vs
//                 [[Ambassador sharedInstance] some_method]
//
+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:nil completion:nil];
}

+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:information completion:completion];
}

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController {
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
}

+ (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    [[AmbassadorSDK sharedInstance] registerConversion:information completion:completion];
}

+ (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email];
}



#pragma mark - Internal API methods
- (void)runWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    universalToken = [NSString stringWithFormat:@"SDKToken %@", universalToken];
    self.universalID = universalID;
    self.universalToken = universalToken;
    self.conversionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkConversionQueue) userInfo:nil repeats:YES];
    self.conversion = [[AMBConversion alloc] initWithKey:universalToken];

    if (information) { // Check if this is the first time opening
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]) {
            DLog(@"Sending conversion on app launch");
            [self registerConversion:information completion:completion];
        }
    }
    
    self.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:self.universalToken];
    [self startPusherUniversalToken:universalToken universalID:universalID completion:^(AMBUserNetworkObject *u, NSError *e) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(e); });
        }
    }];
  
    // Set launch flag in User Deafaults
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY];
}

- (void)pusherChannel:(void(^)(NSString *, NSError *))c {
    AMBPusherSessionSubscribeNetworkObject *o = [AMBPusherSessionSubscribeNetworkObject loadFromDisk];
    if (o && !o.isExpired) {
        if (c) {
            dispatch_async(dispatch_get_main_queue(), ^{ c(o.channel_name, nil); }); }
    } else {
        [[AMBAmbassadorNetworkManager sharedInstance] pusherChannelNameUniversalToken:self.universalToken universalID:self.universalID completion:c];
    }
}

- (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBUserNetworkObject* u, NSError* e))c {
    __weak AmbassadorSDK *weakSelf = self;
    [self pusherChannel:^(NSString *s, NSError *e) {
        if (e) {
             if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, e); }); }
        } else {
            [weakSelf.pusherManager subscribeTo:s completion:^(AMBPTPusherChannel *chan, NSError *e) {
                if (e) {
                    if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, e); }); }
                } else {
                    [weakSelf.pusherManager bindToChannelEvent:@"identify_action" handler:^(AMBPTPusherEvent *ev) {
                        NSMutableDictionary *json = (NSMutableDictionary *)ev.data;
                        AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
                        if (json[@"url"]) {
                            [user fillWithUrl:json[@"url"] universalToken:uTok universalID:uID completion:^(NSError *e) {
                            [user save];
                                if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(user, e); }); }
                            }];
                        } else {
                            [user fillWithDictionary:json];
                            [user save];
                            if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(user, e); }); }
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)sendIdentifyWithEmail:(NSString *)email campaign:(NSString *)campaign enroll:(BOOL)enroll {
    AMBIdentifyNetworkObject *o = [[AMBIdentifyNetworkObject alloc] init];
    o.email = AMBOptionalString(email);
    o.campaign_id = AMBOptionalString(campaign);
    o.enroll = enroll;
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
    raf.APIKey = self.universalToken;
    raf.campaignID = ID;

    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion
{
    DLog();
    [self.conversion registerConversionWithParameters:information completion:completion];
}

- (void)identifyWithEmail:(NSString *)email
{
    DLog();
    //[identify identifyWithEmail:email];
}



#pragma mark - Helper functions
- (void)checkConversionQueue
{
    DLog();
    [self.conversion sendConversions];
}

- (void)throwErrorBlock:(void(^)(NSError *))b error:(NSError *)e {
    if (b) { dispatch_async(dispatch_get_main_queue(), ^{ b(e); }); }
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
