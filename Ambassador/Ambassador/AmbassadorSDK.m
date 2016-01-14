//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBIdentify.h"
#import "AMBConversion.h"
#import "AMBConversionParameters.h"
#import "AMBServiceSelector.h"
#import "AMBPusherManager.h"
#import "AMBNetworkManager.h"

@interface AmbassadorSDK ()

@property (nonatomic, strong) AMBIdentify *identify;
@property (nonatomic, strong) NSTimer *conversionTimer;
@property (nonatomic, strong) AMBConversion *conversion;

@end


@implementation AmbassadorSDK

#pragma mark - LifeCycle

+ (AmbassadorSDK *)sharedInstance {
    static AmbassadorSDK* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AmbassadorSDK alloc] init];
        _sharedInsance.identify = [[AMBIdentify alloc] init];
    });
    
    return _sharedInsance;
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


#pragma mark - Identify

+ (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] localIdentifyWithEmail:email];
}

- (void)localIdentifyWithEmail:(NSString*)email {
    [AMBValues setUserEmail:email];
    [self subscribeToPusherWithCompletion:nil];
}


#pragma mark - Conversions

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


#pragma mark - RAF

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist {
    if (!themePlist || [themePlist isEqualToString:@""]) { themePlist = @"GenericTheme"; }
    [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController withThemePlist:themePlist];
}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist {
    // Initialize root view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    UINavigationController *nav = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    AMBServiceSelector *serviceSelectorVC = (AMBServiceSelector *)nav.childViewControllers[0];
    serviceSelectorVC.campaignID = ID;
    serviceSelectorVC.themeName = themePlist;

    [viewController presentViewController:nav animated:YES completion:nil];
}


#pragma mark - Pusher

- (void)subscribeToPusherWithCompletion:(void(^)())completion {
    if (!self.pusherManager) { self.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:self.universalToken]; }
    
    [[AMBNetworkManager sharedInstance] getPusherSessionWithSuccess:^(NSDictionary *response) {
        [AMBValues setPusherChannelObject:response];
        [self.pusherManager subscribeToChannel:[AMBValues getPusherChannelObject].channelName completion:^(AMBPTPusherChannel *pusherChannel, NSError *error) {
            if (!error) {
                [self.pusherManager bindToChannelEvent:@"identify_action"];
                [self.identify getIdentity];
            } else {
                DLog(@"Error binding to pusher channel - %@", error);
            }
            
            if (completion) { completion(); }
        }];
    } failure:^(NSString *error) {
        DLog(@"Unable to get PUSHER SESSION");
    }];
}

@end
