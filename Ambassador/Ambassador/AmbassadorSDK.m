//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "AmbassadorSDK_Internal.h"
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
#import "AMBPusherChannelObject.h"


#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -


@interface AmbassadorSDK ()
@property (nonatomic, strong) AMBIdentify *identify;
@property (nonatomic, strong) AMBNetworkManager *ambassadorNetworkManager;
@property (nonatomic, strong) NSTimer *conversionTimer;
@property (nonatomic, strong) AMBConversion *conversion;
@property (nonatomic) BOOL hasBeenBoundToChannel;

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
        self.pusherChannelObj = [[AMBPusherChannelObject alloc] init];
    }
    return self;
}


#pragma mark - conversion

+ (void)registerConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(NSError *error))completion {
    [[AmbassadorSDK sharedInstance] localRegisterConversion:conversionParameters restrictToInstall:restrictToInstall completion:completion];
}

- (void)localRegisterConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(NSError *error))completion {
    if (restrictToInstall && ![AMBValues getHasInstalledBoolean]) {
        [self.conversion registerConversionWithParameters:conversionParameters completion:completion];
        [AMBValues setHasInstalled];
        return;
    }
    
    if (restrictToInstall && [AMBValues getHasInstalledBoolean]) {
        completion([NSError errorWithDomain:@"This conversion is restricted to install." code:0 userInfo:nil]);
        return;
    }
    
    if (!restrictToInstall) { [self.conversion registerConversionWithParameters:conversionParameters completion:completion]; }
}

- (void)checkConversionQueue {
    [self.conversion sendConversions];
}


#pragma mark - RunWith Functions

+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    [[AmbassadorSDK sharedInstance] localRunWithuniversalToken:universalToken universalID:universalID];
}

- (void)localRunWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    universalToken = [NSString stringWithFormat:@"SDKToken %@", universalToken];
    self.universalID = universalID;
    self.universalToken = universalToken;
    [AMBValues setUniversalIDWithID:universalID];
    [AMBValues setUniversalTokenWithToken:universalToken];
    if (!self.conversionTimer.isValid) { self.conversionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkConversionQueue) userInfo:nil repeats:YES]; }
    self.conversion = [[AMBConversion alloc] init];
}


#pragma mark - pusher

+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *))c {
    [[AmbassadorSDK sharedInstance] pusherChannelUniversalToken:uTok universalID:uID completion:c];
}

- (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *))c {
    [[AMBAmbassadorNetworkManager sharedInstance] pusherChannelNameUniversalToken:uTok universalID:uID completion:c];
}

+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c {
    [[AmbassadorSDK sharedInstance] startPusherUniversalToken:uTok universalID:uID completion:c];
}

- (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c {
    [[AmbassadorSDK sharedInstance] pusherChannelUniversalToken:uTok universalID:uID completion:^(NSString *s, NSMutableDictionary *pusherChanDic, NSError *e) {
        if (e) {
             if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, e); }); }
        } else {
            if (![AmbassadorSDK sharedInstance].pusherChannelObj.channelName || [[AmbassadorSDK sharedInstance].pusherChannelObj.channelName isEqualToString:@""]) {
                [[AmbassadorSDK sharedInstance].pusherManager subscribeTo:s pusherChanDict:pusherChanDic completion:c];
            }
        }
    }];
}

+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID {
    [[AmbassadorSDK sharedInstance] bindToIdentifyActionUniversalToken:uTok universalID:uID];
}

- (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID {
    [AmbassadorSDK sharedInstance].hasBeenBoundToChannel = YES;
    [self.pusherManager bindToChannelEvent:@"identify_action" handler:^(AMBPTPusherEvent *ev) {
        NSMutableDictionary *json = (NSMutableDictionary *)ev.data[@"body"];
        AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
        if (ev.data[@"url"]) {
            [user fillWithUrl:ev.data[@"url"] universalToken:uTok universalID:uID completion:^(NSError *e) {
                [AmbassadorSDK sharedInstance].user = user;
                [AMBValues setUserFirstNameWithString:user.first_name];
                [AMBValues setUserLastNameWithString:user.last_name];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
            }];
        } else if (json[@"mbsy_cookie_code"] && json[@"mbsy_cookie_code"] != [NSNull null]) {
            DLog(@"MBSY COOKIE = %@ and FINGERPRINT = %@", json[@"mbsy_cookie_code"], json[@"fingerprint"]);
            [AMBValues setMbsyCookieWithCode:json[@"mbsy_cookie_code"]]; // Saves mbsy cookie to defaults
            [AMBValues setDeviceFingerPrintWithDictionary:json[@"fingerprint"]]; // Saves device fp to defaults
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceInfoReceived" object:nil];
        } else {
            [user fillWithDictionary:json];
            [AmbassadorSDK sharedInstance].user = user;
            [AMBValues setUserFirstNameWithString:user.first_name];
            [AMBValues setUserLastNameWithString:user.last_name];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
        }
    }];
}

#pragma mark - Identify

+ (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email completion:nil];
}

+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email completion:c];
}

- (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c {
    self.email = email;
    [AMBValues setUserEmail:email];
    __weak AmbassadorSDK *weakSelf = self;
    if (!self.pusherManager) {
        self.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:self.universalToken];
    }
    
    [self startPusherUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID completion:^(AMBPTPusherChannel* chan, NSError *e) {
        if (![AmbassadorSDK sharedInstance].hasBeenBoundToChannel) {
            [self bindToIdentifyActionUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID];
        }
        
        [self.identify identifyWithUniversalID:self.universalID completion:^(NSMutableDictionary *returnDict, NSError *error) {
            nil;
        }];
        
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
    }];
    
    NSError *error;
    if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(error); }); }
}

+ (void)sendIdentifyWithCampaign:(NSString *)campaign enroll:(BOOL)enroll completion:(void(^)(NSError *))c {
    [[AmbassadorSDK sharedInstance] sendIdentifyWithCampaign:campaign enroll:enroll completion:c];
}

- (void)sendIdentifyWithCampaign:(NSString *)campaign enroll:(BOOL)enroll completion:(void(^)(NSError *e))c {
    AMBIdentifyNetworkObject *o = [[AMBIdentifyNetworkObject alloc] init];
    o.email = AMBOptionalString([AmbassadorSDK sharedInstance].email);
    o.campaign_id = AMBOptionalString(campaign);
    o.enroll = enroll;
    o.fp = (self.identify.fp) ? self.identify.fp : (NSMutableDictionary*)@{};
    
    DLog(@"The fingerprint getting sent in send identify: %@", o.fp);

    NSMutableDictionary *extraHeaders = [[AmbassadorSDK sharedInstance].pusherChannelObj createAdditionalNetworkHeaders];
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:o url:[AMBAmbassadorNetworkManager sendIdentifyUrl] additionParams:extraHeaders requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
    }];
}


#pragma mark - RAF

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController {
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController {
    // Initialize root view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    UINavigationController *vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    raf = (AMBServiceSelector *)vc.childViewControllers[0];
    raf.campaignID = ID;
    
    AMBServiceSelectorPreferences *prefs = [[AMBServiceSelectorPreferences alloc] init];
    prefs.titleLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFWelcomeTextMessage];
    prefs.descriptionLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFDescriptionTextMessage];
    prefs.defaultShareMessage = [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage];
    prefs.navBarTitle = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    raf.prefs = prefs;

    [viewController presentViewController:vc animated:YES completion:nil];
}



#pragma mark - Helper functions

- (void)throwErrorBlock:(void(^)(NSError *))b error:(NSError *)e {
    if (b) { dispatch_async(dispatch_get_main_queue(), ^{ b(e); }); }
}

@end
