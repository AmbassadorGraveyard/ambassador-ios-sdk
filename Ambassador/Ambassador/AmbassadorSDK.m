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

+ (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    [[AmbassadorSDK sharedInstance] registerConversion:information completion:completion];
}

- (void)registerConversion:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    [self.conversion registerConversionWithParameters:information completion:completion];
}

- (void)checkConversionQueue {
    [self.conversion sendConversions];
}


#pragma mark - runWith

+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:nil completion:nil];
}

+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    [[AmbassadorSDK sharedInstance] runWithuniversalToken:universalToken universalID:universalID convertOnInstall:information completion:completion];
}

- (void)runWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(AMBConversionParameters *)information completion:(void (^)(NSError *error))completion {
    universalToken = [NSString stringWithFormat:@"SDKToken %@", universalToken];
    self.universalID = universalID;
    self.universalToken = universalToken;
    [[NSUserDefaults standardUserDefaults] setValue:universalID forKey:AMB_UNIVERSAL_ID_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:universalToken forKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY];
    self.conversionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkConversionQueue) userInfo:nil repeats:YES];
    self.conversion = [[AMBConversion alloc] initWithKey:universalToken];

    if (information) { // Check if this is the first time opening
        if (![[NSUserDefaults standardUserDefaults] objectForKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]) {
            DLog(@"Sending conversion on app launch");
            [self registerConversion:information completion:completion];
        }
    }

    [self.identify identifyWithURL:[AMBIdentify identifyUrlWithUniversalID:universalID] completion:^(NSMutableDictionary *resp, NSError *e) {
        // TODO: save id
        self.identify.fp  = resp;
        DLog(@"Received identify fingerprint");
    }];
  
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]; // Set launch flag in User Deafaults
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
        NSMutableDictionary *json = (NSMutableDictionary *)ev.data;
        AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
        if (json[@"url"]) {
            [user fillWithUrl:json[@"url"] universalToken:uTok universalID:uID completion:^(NSError *e) {
                [AmbassadorSDK sharedInstance].user = user;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
                // TODO: Notification Center
            }];
        } else {
            [user fillWithDictionary:json];
            [AmbassadorSDK sharedInstance].user = user;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
        }
    }];
}

#pragma mark - Identify

+ (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email];
}

- (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email completion:nil];
}

+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c {
    [[AmbassadorSDK sharedInstance] identifyWithEmail:email completion:c];
}

- (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c {
    self.email = email;
    __weak AmbassadorSDK *weakSelf = self;
    if (!self.pusherManager) {
        self.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:self.universalToken];
    }
    
    [self startPusherUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID completion:^(AMBPTPusherChannel* chan, NSError *e) {
        if (![AmbassadorSDK sharedInstance].hasBeenBoundToChannel) {
            [self bindToIdentifyActionUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID];
        }
        
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
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:o url:[AMBAmbassadorNetworkManager sendIdentifyUrl] universalToken:[AmbassadorSDK sharedInstance].universalToken universalID:[AmbassadorSDK sharedInstance].universalID additionParams:extraHeaders completion:^(NSData *d, NSURLResponse *r, NSError *e) {
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
    
    AMBServiceSelectorPreferences *prefs = [[AMBServiceSelectorPreferences alloc] init];
    prefs.titleLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFWelcomeTextMessage];
    prefs.descriptionLabelText = [[AMBThemeManager sharedInstance] messageForKey:RAFDescriptionTextMessage];
    prefs.defaultShareMessage = [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage];
    prefs.navBarTitle = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    raf.prefs = prefs;
    raf.APIKey = self.universalToken;
    raf.campaignID = ID;

    [viewController presentViewController:vc animated:YES completion:nil];
}



#pragma mark - Helper functions

- (void)throwErrorBlock:(void(^)(NSError *))b error:(NSError *)e {
    if (b) { dispatch_async(dispatch_get_main_queue(), ^{ b(e); }); }
}

@end
