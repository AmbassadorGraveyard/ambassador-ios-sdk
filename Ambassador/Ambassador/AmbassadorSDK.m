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


#pragma mark - Local Constants
float const AMB_CONVERSION_FLUSH_TIME = 10.0;
NSString * const AMBASSADOR_INFO_URLS_KEY = @"urls";
NSString * const CAMPAIGN_UID_KEY = @"campaign_uid";
NSString * const SHORT_CODE_KEY = @"short_code";
NSString * const SHORT_CODE_URL_KEY = @"url";
#pragma mark -


@interface AmbassadorSDK ()
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
    }];
  
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:AMB_FIRST_LAUNCH_USER_DEFAULTS_KEY]; // Set launch flag in User Deafaults
}



#pragma mark - pusher
+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSError *))c {
    [[AmbassadorSDK sharedInstance] pusherChannelUniversalToken:uTok universalID:uID completion:c];
}

- (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSError *))c {
    AMBPusherSessionSubscribeNetworkObject *o = [AMBPusherSessionSubscribeNetworkObject loadFromDisk];
    if (o && !o.isExpired) {
        if (c) {
            dispatch_async(dispatch_get_main_queue(), ^{ c(o.channel_name, nil); }); }
    } else {
        [[AMBAmbassadorNetworkManager sharedInstance] pusherChannelNameUniversalToken:uTok universalID:uID completion:c];
    }
}

+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c {
    [[AmbassadorSDK sharedInstance] startPusherUniversalToken:uTok universalID:uID completion:c];
}

- (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c {
    __weak AmbassadorSDK *weakSelf = self;
    [self pusherChannelUniversalToken:uTok universalID:uID completion:^(NSString *s, NSError *e) {
        if (e) {
             if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, e); }); }
        } else {
            [weakSelf.pusherManager subscribeTo:s completion:c];
        }
    }];
}

+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID {
    [[AmbassadorSDK sharedInstance] bindToIdentifyActionUniversalToken:uTok universalID:uID];
}

- (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID {
    __weak AmbassadorSDK *weakSelf = self;
    [weakSelf.pusherManager bindToChannelEvent:@"identify_action" handler:^(AMBPTPusherEvent *ev) {
        NSMutableDictionary *json = (NSMutableDictionary *)ev.data;
        AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
        if (json[@"url"]) {
            [user fillWithUrl:json[@"url"] universalToken:uTok universalID:uID completion:^(NSError *e) {
                weakSelf.user = user;
                // TODO: Notification Center
            }];
        } else {
            [user fillWithDictionary:json];
            weakSelf.user = user;
            // TODO: Notification Center
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
    self.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:self.universalToken];
    [self startPusherUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID completion:^(AMBPTPusherChannel* chan, NSError *e) {
        [weakSelf bindToIdentifyActionUniversalToken:weakSelf.universalToken universalID:weakSelf.universalID];
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
    }];
}

+ (void)sendIdentifyWithEmail:(NSString *)email campaign:(NSString *)campaign enroll:(BOOL)enroll universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c {
    [[AmbassadorSDK sharedInstance] sendIdentifyWithEmail:email campaign:campaign enroll:enroll universalToken:uTok universalID:uID completion:c];
}

- (void)sendIdentifyWithEmail:(NSString *)email campaign:(NSString *)campaign enroll:(BOOL)enroll universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c {
    AMBIdentifyNetworkObject *o = [[AMBIdentifyNetworkObject alloc] init];
    o.email = AMBOptionalString(email);
    o.campaign_id = AMBOptionalString(campaign);
    o.enroll = enroll;

    NSMutableDictionary *extraHeaders = [[AMBPusherSessionSubscribeNetworkObject loadFromDisk] additionalNetworkHeaders];
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:o url:[AMBAmbassadorNetworkManager sendIdentifyUrl] universalToken:uTok universalID:uID additionParams:extraHeaders completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
    }];
}



#pragma mark - RAF
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController {
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController {
    NSString *shortCodeURL = @"";
    NSString *shortCode = @"";
    [[NSUserDefaults standardUserDefaults] setValue:ID forKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY];
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
    if (userInfo) {
        NSArray* urls = userInfo[AMBASSADOR_INFO_URLS_KEY];
        for (NSDictionary *url in urls) {
            NSString *campaignID = [NSString stringWithFormat:@"%@", url[CAMPAIGN_UID_KEY]];
            if ([campaignID isEqualToString:ID]) {
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



#pragma mark - Helper functions
- (void)throwErrorBlock:(void(^)(NSError *))b error:(NSError *)e {
    if (b) { dispatch_async(dispatch_get_main_queue(), ^{ b(e); }); }
}



#pragma mark - 
+ (void)setUpdatedUserInfoCompletion:(void(^)(AMBUserNetworkObject *, NSError *))c {
    
}

@end
