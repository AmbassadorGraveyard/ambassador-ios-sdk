//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AmbassadorSDK.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBConversion.h"
#import "AMBConversionParameters.h"
#import "AMBServiceSelector.h"
#import "AMBPusherManager.h"
#import "AMBNetworkManager.h"
#import "AMBErrors.h"
#import "RavenClient.h"


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
    
    // Init our AMBConversion object if not already
    if (!self.conversion) { self.conversion = [[AMBConversion alloc] init]; }
    
    // Checks for any unsent conversions from the last session and sends them off if able
    [self.conversion retryUnsentConversions];

    // Sets up Sentry Crash Analytics
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

+ (void)identifyWithUserID:(NSString *)userID traits:(NSDictionary *)traits {
    [[AmbassadorSDK sharedInstance] localIdentifyWithUserID:userID traits:traits];
}

+ (void)identifyWithEmail:(NSString *)email {
    // Uses new idenity logic when deprecated identify method is called
    [[AmbassadorSDK sharedInstance] localIdentifyWithUserID:email traits:@{@"email" : email}];
}

- (void)localIdentifyWithUserID:(NSString *)userID traits:(NSDictionary *)traits {
    // Creates an identify object and saves it to user defaults
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] initWithUserID:userID traits:traits];
    [AMBValues setUserIdentifyObject:identifyObject];
    
    // Sends the APN token to the backend
    [self sendAPNDeviceToken];
    
    // Clears out the previous campaign list to avoid unauthorized access to RAF
    [AMBValues setUserCampaignList:nil];
    
    // Subscribes to Pusher with a brand new channel since the old one is likely disconnected/terminated
    [self subscribeToPusherWithSuccess:^{
        // Perfom identify request to get and save campaigns to local storage
        [[AMBNetworkManager sharedInstance] sendIdentifyForCampaign:nil shouldEnroll:NO success:^(NSString *response) {
            DLog(@"SEND IDENTIFY Response - %@", response);
        } failure:^(NSString *error) {
            DLog(@"SEND IDENTIFY Response - %@", error);
        }];
        
        // If not already performed, we perform the safariVC identify to get shortCode and device FP
        if (!self.identify.identifyProcessComplete) { [self.identify getIdentity]; }
    }];
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


#pragma mark - RAF

+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist {
    if (!themePlist || [themePlist isEqualToString:@""]) { themePlist = @"GenericTheme"; }
    
    // Checks to see if we have the user email
    if (![AMBValues getUserIdentifyObject]) {
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
    [self localIdentifyWithUserID:inputValue traits:@{@"email" : inputValue}];
    [self presentRAFForCampaign:self.tempCampID FromViewController:self.tempPresentController withThemePlist:self.tempPlistName];
}


#pragma mark - Pusher

- (void)subscribeToPusherWithSuccess:(void(^)())success {
    // We need to recreate the pusher manager here, because it may be running on bad tokens from a previous attempt
    self.pusherManager = [[AMBPusherManager alloc] initWithAuthorization:[AMBValues getUniversalToken]];

    [[AMBNetworkManager sharedInstance] getPusherSessionWithSuccess:^(NSDictionary *response) {
        // Save the pusherChannel info from the backend to defautls
        [AMBValues setPusherChannelObject:response];
        
        // Subscribe to the pusher channel that we got from the backend
        [self.pusherManager subscribeToChannel:[AMBValues getPusherChannelObject].channelName completion:^(AMBPTPusherChannel *pusherChannel, NSError *error) {
            if (!error) {
                // Once subscribed to our channel, we bind to the identify event
                [self.pusherManager bindToChannelEvent:@"identify_action"];
                
                // Triggers completion block
                if (success) { success(); }
            } else {
                DLog(@"Error binding to pusher channel - %@", error);
            }
        }];
    
    // If the account doesn't have SDK Access
    } noSDKAccess:^{
        // Prints sdk access error to user
        [AMBErrors errorNoSDKAccess];
        
        // Gets the top most view controller to see if it's the RAF
        UIViewController *controller = [AMBUtilities getTopViewController];
        
        // Checks the restoration id set in storyboards for the RAF nav -- If it's the RAF a message is presented
        if ([controller.restorationIdentifier isEqualToString:@"RAFNAVID"]) {
            [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You currently don't have access to the SDK. If you have any questions please contact support." withUniqueID:nil forViewController:controller shouldDismissVCImmediately:YES];
        }
        
    // If some other error happens when attempting to subscribe to pusher
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

+ (void)presentNPSSurveyWithNotification:(NSDictionary*)notification {
    [[AmbassadorSDK sharedInstance] localPresentNPSSurveyWithNotification:notification action:^{
        [[AmbassadorSDK sharedInstance] presentNPSSurvey];
    }];
}

+ (void)presentNPSSurveyWithNotification:(NSDictionary *)notification backgroundColor:(UIColor *)backgroundColor contentColor:(UIColor *)contentColor buttonColor:(UIColor *)buttonColor {
    [AmbassadorSDK sharedInstance].npsBackgroundColor = backgroundColor;
    [AmbassadorSDK sharedInstance].npsContentColor = contentColor;
    [AmbassadorSDK sharedInstance].npsButtonColor = buttonColor;
    
    [[AmbassadorSDK sharedInstance] localPresentNPSSurveyWithNotification:notification action:^{
        [[AmbassadorSDK sharedInstance] presentThemedNPSSurveyWithBackgroundColor:backgroundColor contentColor:contentColor buttonColor:buttonColor];
    }];
}

- (void)localPresentNPSSurveyWithNotification:(NSDictionary *)notification action:(void(^)())action {
    DLog(@"AmbassadorNotification Received - %@", notification);
    
    // Grab the notification to use elsewhere in AmbassadorSDK
    [AmbassadorSDK sharedInstance].notificationData = notification;
    
    // Checks if the app is already open and shows an alert if so
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Can you help us out by taking a quick survey?" delegate:[AmbassadorSDK sharedInstance] cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView show];
        
        // If the user taps on the app when in the background then we skip the alertView
    } else {
        // If an action is passed in, the action is performed
        if (action) { action(); }
    }
}

- (void)presentNPSSurvey {
    [[AmbassadorSDK sharedInstance] presentThemedNPSSurveyWithBackgroundColor:nil contentColor:nil buttonColor:nil];
}

- (void)presentThemedNPSSurveyWithBackgroundColor:(UIColor *)backgroundColor contentColor:(UIColor *)contentColor buttonColor:(UIColor *)buttonColor {
    // Grabs the top-most viewController
    UIViewController *topViewController = [AMBUtilities getTopViewController];
    
    // Creates an NPS survey ViewController and has the top-most VC present it
    AMBNPSViewController *npsViewController = [[AMBNPSViewController alloc] initWithPayload: self.notificationData];
    npsViewController.mainBackgroundColor = backgroundColor;
    npsViewController.contentColor = contentColor;
    npsViewController.buttonColor = buttonColor;
    [topViewController presentViewController:npsViewController animated:YES completion:nil];
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


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // If there are temp colors set, we present the themed NPS controller
        if ([AmbassadorSDK sharedInstance].npsBackgroundColor || [AmbassadorSDK sharedInstance].npsContentColor || [AmbassadorSDK sharedInstance].npsButtonColor) {
            [[AmbassadorSDK sharedInstance] presentThemedNPSSurveyWithBackgroundColor:[AmbassadorSDK sharedInstance].npsBackgroundColor contentColor:[AmbassadorSDK sharedInstance].npsContentColor buttonColor:[AmbassadorSDK sharedInstance].npsButtonColor];
            
            // Sets the temp colors to nil
            [AmbassadorSDK sharedInstance].npsBackgroundColor = nil;
            [AmbassadorSDK sharedInstance].npsContentColor = nil;
            [AmbassadorSDK sharedInstance].npsButtonColor = nil;
        } else {
            // Once the alertView is dismissed is when we want to present the survey
            [self presentNPSSurvey];
        }
    }
}

@end
