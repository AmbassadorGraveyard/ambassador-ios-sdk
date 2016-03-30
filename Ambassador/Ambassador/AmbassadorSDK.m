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
#import "AMBErrors.h"
#import "RavenClient.h"

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


#pragma mark - Crash Analytics

NSUncaughtExceptionHandler *parentHandler = nil;

void ambassadorUncaughtExceptionHandler(NSException *exception) {
    if (stackTraceForContainsString(exception, @"AmbassadorSDK")) {
        [[RavenClient sharedClient] captureException:exception sendNow:NO];
    }
    
    // If the parent app has an exceptionHandler already, we call it
    if (parentHandler) {
        parentHandler(exception);
    }
}

BOOL stackTraceForContainsString(NSException *exception, NSString *keyString) {
    NSArray *callStackArray = [NSArray arrayWithArray:exception.callStackSymbols];
    for (NSMutableString *callBackString in callStackArray) {
        if ([callBackString containsString:keyString]) {
            return YES;
        }
    }
    
    return NO;
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
    [AMBValues setPusherChannelObject:@{}];
    if (!self.conversionTimer.isValid) { self.conversionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkConversionQueue) userInfo:nil repeats:YES]; }
    self.conversion = [[AMBConversion alloc] init];

    [self setUpCrashAnalytics];
}

- (void)setUpCrashAnalytics {
    // Sets up Sentry if in release mode
    if ([AMBValues isProduction]) {
        RavenClient *client = [RavenClient clientWithDSN:[AMBValues getSentryDSNValue]];
        [RavenClient setSharedClient:client];
        parentHandler = NSGetUncaughtExceptionHandler(); // Creates a reference to parent project's exceptionHandler in order to fire it in override
        
        [[RavenClient sharedClient] setupExceptionHandler]; // Is overridden to use our custom handler but still grabs crashes
        NSSetUncaughtExceptionHandler(ambassadorUncaughtExceptionHandler); // Sets our overridden exceptionHandler that only sends on AmbassadorSDK stacktraces
    }
}


#pragma mark - Identify

+ (void)identifyWithEmail:(NSString *)email {
    [[AmbassadorSDK sharedInstance] localIdentifyWithEmail:email];
}

- (void)localIdentifyWithEmail:(NSString*)email {
    [AMBValues setUserEmail:email];
    [self sendAPNDeviceToken];
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
        completion([AMBErrors restrictedConversionError]);
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
    
    // Checks to see if we have the user email
    if (![AMBValues getUserEmail] || [AMBUtilities stringIsEmpty:[AMBValues getUserEmail]]) {
        // If we do NOT have it, we present an email prompt
        [[AmbassadorSDK sharedInstance] presentEmailPrompt:viewController campID:ID themePlist:themePlist];
    } else {
        // Otherwise- present RAF as normal
        [[AmbassadorSDK sharedInstance] presentRAFForCampaign:ID FromViewController:viewController withThemePlist:themePlist];
    }
}

- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist {
    // Initialize root view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    UINavigationController *nav = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"RAFNAV"];
    AMBServiceSelector *serviceSelectorVC = (AMBServiceSelector *)nav.childViewControllers[0];
    serviceSelectorVC.campaignID = ID;
    serviceSelectorVC.themeName = themePlist;

    [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)presentEmailPrompt:(UIViewController*)viewController campID:(NSString*)campID themePlist:(NSString*)themePlist {
    // Temporarily saves values to use for presenting raf on continuation
    self.tempCampID = campID;
    self.tempPresentController = viewController;
    self.tempPlistName = themePlist;
    
    AMBInputAlert *emailAlert = [[AMBInputAlert alloc] initWithTitle:@"Refer your friends!" message:@"Enter your email below to get started." placeHolder:@"Email" actionButton:@"Continue"];
    emailAlert.delegate = self;
    [viewController presentViewController:emailAlert animated:YES completion:nil];
}

// AMBInputAlert Delegate
- (void)AMBInputAlertActionButtonTapped:(NSString *)inputValue {
    [self localIdentifyWithEmail:inputValue];
    [self presentRAFForCampaign:self.tempCampID FromViewController:self.tempPresentController withThemePlist:self.tempPlistName];
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


#pragma mark - Remote Notifications

+ (void)registerDeviceToken:(NSString*)deviceToken {
    if (deviceToken && ![deviceToken isEqualToString:@""]) {
        [AMBValues setAPNDeviceToken:deviceToken];
    }
}

- (void)sendAPNDeviceToken {
    if ([AMBValues getAPNDeviceToken] && ![[AMBValues getAPNDeviceToken] isEqualToString:@""] && ![[AMBValues getUserEmail] isEqualToString:@""]) {
        [[AMBNetworkManager sharedInstance] updateAPNDeviceToken:[AMBValues getAPNDeviceToken] success:nil failure:nil];
    }
}

+ (void)handleAmbassadorRemoteNotification:(NSDictionary*)notification {
    // TODO: Add functionality when surveys are implemented into app
    DLog(@"AmbassadorNotification Received - %@", notification);
}


#pragma mark - Welcome Screen

+ (void)presentWelcomeScreen:(AMBWelcomeScreenParameters*)parameters ifAvailable:(void(^)(AMBWelcomeScreenViewController *welcomeScreenVC))available {
    if (![AMBUtilities stringIsEmpty:[AMBValues getMbsyCookieCode]]) {
        [[AMBNetworkManager sharedInstance] getReferrerInformationWithSuccess:^(NSDictionary *referrerInfo) {
            // Create new VC from storyboard
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
            AMBWelcomeScreenViewController *welcomeController = (AMBWelcomeScreenViewController*)[sb instantiateViewControllerWithIdentifier:@"WELCOME_SCREEN"];
            
            // Set image and name values from response
            NSData *imageUrlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:referrerInfo[@"avatar_url"]]];
            welcomeController.referrerImage = [UIImage imageWithData:imageUrlData];
            welcomeController.referrerName = referrerInfo[@"name"];
            
            welcomeController.parameters = parameters;
            if (available) { available(welcomeController); }
        } failure:^(NSString *error) {
            DLog(@"Could not create the Welcome Screen - %@", error);
        }];
    }
}

@end
