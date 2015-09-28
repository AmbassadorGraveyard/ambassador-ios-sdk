//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "AMBIdentify.h"
<<<<<<< HEAD
#import "AMBCoreDataManager.h"
#import "AMBAmbassadorNetworking.h"
#import "AMBIdentifyNetworkObject.h"
#import "AMBPusherManager.h"
#import "AMBConversionFieldsCoreDataObject.h"
=======
#import "AMBConversion.h"
#import "AMBConversionParameters.h"
#import "AMBUtilities.h"
#import "AMBServiceSelector.h"
#import "AMBServiceSelectorPreferences.h"
#import "AMBThemeManager.h"
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e

#import "AMBUserNetworkObject.h"

@interface AmbassadorSDK ()
@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) NSString *universalID;

@property (nonatomic, strong) AMBIdentify *identify;
@property (nonatomic, strong) AMBAmbassadorNetworking *ambNetworking;
@property (nonatomic, strong) AMBCoreDataManager *ambCoreData;
@property (nonatomic, strong) AMBPusherManager *ambPusher;

@property (nonatomic, copy) void (^sendConversionCompletion)(NSError *e);
@end


@implementation AmbassadorSDK
#pragma mark - Initialization
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.identify = [[AMBIdentify alloc] init];
        self.ambNetworking = [[AMBAmbassadorNetworking alloc] init];
        self.ambCoreData = [[AMBCoreDataManager alloc] init];
    }
    return self;
}



<<<<<<< HEAD
#pragma mark - Set Up
+ (void)ambassadorWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    [[AmbassadorSDK sharedInstance] ambassadorWithUniversalToken:universalToken universalID:universalID];
    [AmbassadorSDK sharedInstance].ambPusher = [[AMBPusherManager alloc] initWith:universalToken universalID:universalID];
=======
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController
{
    DLog();
    
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController];
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
}

- (void)ambassadorWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID {
    [AmbassadorSDK sharedInstance].universalToken = universalToken;
    [AmbassadorSDK sharedInstance].universalID = universalID;
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(sendConversions) userInfo:nil repeats:YES];
}



#pragma mark - Identify
+ (void)identify:(NSString *)email completion:(void(^)(NSError *))completion {
    [[AmbassadorSDK sharedInstance] identify:email completion:completion];
}

- (void)identify:(NSString *)email completion:(void(^)(NSError *))completion {
    __weak AmbassadorSDK *weakSelf = [AmbassadorSDK sharedInstance];
    NSString *idenfityURL = [NSString stringWithFormat:@"https://staging.mbsy.co/universal/landing/?url=ambassador:ios&universal_id=%@", self.universalID];
    [[AmbassadorSDK sharedInstance].identify identifyWithURL:idenfityURL completion:^(NSMutableDictionary *resp, NSError *e) {
        if (e) {
            [weakSelf throwIdentifyError:e block:completion];
        } else {
            AMBIdentifyNetworkObject *iNetObj = [[AMBIdentifyNetworkObject alloc] init];
            iNetObj.fp = resp;
            iNetObj.email = email;
            [[AmbassadorSDK sharedInstance].ambCoreData saveIdentifyData:iNetObj completion:^(NSError *e) {
                if (e) {
                    [weakSelf throwIdentifyError:e block:completion];
                } else {
                    [[AmbassadorSDK sharedInstance].ambPusher subscribe:resp[@"device"][@"ID"] completion:^(AMBPTPusherChannel *chan, NSError *e) {
                        if (e) {
                            [weakSelf throwIdentifyError:e block:completion];
                        } else {
                            [[AmbassadorSDK sharedInstance].ambPusher bindToChannelEvent:@"identify_action" handler:^(AMBPTPusherEvent *ev) {
                                AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
                                [user fillFrom:ev.data];
                                [[AmbassadorSDK sharedInstance].ambCoreData saveUserData:user completion:^(NSError *e) {
                                    [weakSelf throwIdentifyError:e block:completion];
                                }];
                            }];
                            [[AmbassadorSDK sharedInstance].ambNetworking sendIdentifyNetworkObj:iNetObj universalToken:weakSelf.universalToken universalID:weakSelf.universalID completion:^(NSData *d, NSURLResponse *r, NSError *e) {
                                if (e) {
                                    [weakSelf throwIdentifyError:e block:completion];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

<<<<<<< HEAD
- (void)throwIdentifyError:(NSError *)e block:(void (^)(NSError *))b {
    if (b) {
        dispatch_async(dispatch_get_main_queue(), ^{ b(e); });
    }
=======
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
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
}



#pragma mark - Conversion
+ (void)conversion:(AMBConversionFieldsNetworkObject *)fields completion:(void (^)(NSError *))completion {
    [[AmbassadorSDK sharedInstance] conversion:fields completion:completion];
}

- (void)conversion:(AMBConversionFieldsNetworkObject *)fields completion:(void (^)(NSError *))completion {
    [[AmbassadorSDK sharedInstance].ambCoreData saveConversionFields:fields completion:completion];
}

+ (void)setSentConversionCompletion:(void(^)(NSError*))completion {
    [AmbassadorSDK sharedInstance].sendConversionCompletion = completion;
}

- (void)sendConversions {
    [[AmbassadorSDK sharedInstance] sendConversions:self.universalToken universalID:self.universalID completion:self.sendConversionCompletion];
}

+ (void)sendConversions:(NSString *)universalToken universalID:(NSString *)universalID completion:(void(^)(NSError*))completion {
    [[AmbassadorSDK sharedInstance] sendConversions:universalToken universalID:universalID completion:completion];
}

- (void)sendConversions:(NSString *)universalToken universalID:(NSString *)universalID completion:(void(^)(NSError*))completion {
    NSMutableDictionary *fp = [AmbassadorSDK sharedInstance].identify.fp;
    if (!fp) {
        NSLog(@"[Ambassador] - Couldn't send conversion fields right now (The user isn't identified yet). We will try again soon.");
        return;
    }
    __weak AmbassadorSDK *weakSelf = [AmbassadorSDK sharedInstance];
    [[AmbassadorSDK sharedInstance].ambCoreData getConversionFields:^(NSArray *results, NSError *e) {
        NSError *error;
        for (AMBConversionFieldsCoreDataObject *result in results) {
            NSMutableDictionary *conversionFields = [NSJSONSerialization JSONObjectWithData:result.ambConversionFieldsNetworkObject options:0 error:&error];
            
            AMBConversionNetworkObject *payload = [[AMBConversionNetworkObject alloc] init];
            payload.fields = conversionFields;
            payload.fp = fp;
            
            [[AmbassadorSDK sharedInstance].ambNetworking sendConversionObj:payload universalToken:weakSelf.universalToken universalID:self.universalID completion:^(NSData *d, NSURLResponse *r, NSError *e) {
                if (e) {
                    if (((NSHTTPURLResponse *)r).statusCode >= 400 && ((NSHTTPURLResponse *)r).statusCode < 500) {
                        NSError * err = AMBBADRESPError(((NSHTTPURLResponse *)r).statusCode, d);
                        [weakSelf throwConversionError:err block:completion];
                        NSLog(@"[Ambassador] - Couldn't send conversion fields. Data may have been malformed. We are removing this from the sending queue. The error was %@", err);
                        [[AmbassadorSDK sharedInstance].ambCoreData removeObject:result completion:^(NSError *e) {
                            [weakSelf throwConversionError:e block:completion];
                        }];
                        return;
                    }
                    [weakSelf throwConversionError:e block:completion];
                    NSLog(@"[Ambassador] - Couldn't send conversion fields. We will try again soon. The error was %@", e);
                    return;
                } else {
                    [[AmbassadorSDK sharedInstance].ambCoreData removeObject:result completion:^(NSError *e) {
                        [weakSelf throwConversionError:e block:completion];
                    }];
                }
            }];
        }
    }];
}

- (void)throwConversionError:(NSError *)e block:(void (^)(NSError *))b {
    if (b) {
        dispatch_async(dispatch_get_main_queue(), ^{ b(e); });
    }
}

@end
