//
//  Ambassador.h
//  Copyright (c) 2015 ZFERRAL INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMBConversionParameters.h"
#import "AMBWelcomeScreenViewController.h"

@interface AmbassadorSDK : NSObject

/**Initializes Ambassador in an application using the provided credentials*/
+ (void)runWithUniversalToken:(NSString *)UniversalToken universalID:(NSString *)universalID;

/**Identifies a user and associates it with the given email*/
+ (void)identifyWithEmail:(NSString *)email;

/**Registers a conversion with Ambassador using the properties set in 'conversionParameters'*/
+ (void)registerConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(NSError *error))completion;

/**Presents a full-page modal 'Refer-A-Friend' (RAF) ViewController*/
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist;

/**Registers a device's APN Device Token in order to send notifications*/
+ (void)registerDeviceToken:(NSString*)deviceToken;

/**Handles remote notifications that are sent from Ambassador**/
+ (void)handleAmbassadorRemoteNotification:(NSDictionary*)notification;

/**Generates a Welcome Screen ViewController based on referrer's data, which can be handled by the caller*/
+ (void)presentWelcomeScreen:(AMBWelcomeScreenParameters*)parameters ifAvailable:(void(^)(AMBWelcomeScreenViewController *welcomeScreenVC))available;

@end
