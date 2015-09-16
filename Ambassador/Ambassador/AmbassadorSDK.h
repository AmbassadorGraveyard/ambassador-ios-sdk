//
//  Ambassador.h
//  Copyright (c) 2015 ZFERRAL INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConversionParameters.h"
#import "ServiceSelectorPreferences.h"

/**
 `Ambassador` is the object that provides access to Ambassador's SDK functionality
 
 Subclassing Notes
 This class is provided as an easy way to integrate Ambassador's services in your iOS app and is not intended to be subclassed. Subclassing may lead to unexpected behavior and stability issues.
 
 Methods to override
 No methods should be overridden. This class is not meant to be subclassed.
 */

@interface AmbassadorSDK : NSObject
///--------------------
/// @name Initial Setup
///--------------------

/**
 Runs an 'Ambassador' object with the specified API key.
 
 @param universalToken The Universal Token provided to you by Ambassador.
 @param universalID The Universal ID provided to you by Ambassador.
 */
+ (void)runWithUniversalToken:(NSString *)UniversalToken universalID:(NSString *)universalID;

/**
 Runs an 'Ambassador' object with the specified API key and parameters for registering a conversion on launch
 
 @param universalToken The Universal Token provided to you by Ambassador.
 @param universalID The Universal ID provided to you by Ambassador.
 @param parameters An instance of ConversionParameters with properties set for registering a conversion on the initial launch of the app.
 @param a completion handler called upon registering the conversion
 Error domain = AmbassadorSDKErrorDomain
 Error codes :
 1   ConversionParameters required properties unset
 2   ConversionParameters property has nil value
 */
+ (void)runWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID convertOnInstall:(ConversionParameters *)information completion:(void (^)(NSError *error))completion;


///------------------------------------
/// @name Core Ambassador Functionality
///------------------------------------

/**
 Identifies a user and associates it with the given email
 
 @param email The user's email to be used in identifying the Ambassador
 */
+ (void)identifyWithEmail:(NSString *)email;

/**
 Registers a conversion with Ambassador per the properties set in 'parameters'
 
 @param parameters An instance of ConversionParameters with properties set for registering a conversion on the initial launch of the app.
 @param a completion handler called upon registering the conversion. 
 Error domain = AmbassadorSDKErrorDomain
 Error codes :
                1   ConversionParameters required properties unset 
                2   ConversionParameters property has nil value
 */
+ (void)registerConversion:(ConversionParameters *)information completion:(void (^)(NSError *error))completion;

/**
 Presents a full-page modal 'Refer-A-Friend' (RAF) view controller
 
 @param ID The Ambassador campaign id with which you would like this RAF associated.
 @param viewController The view controller from which you would like to present the RAF.
 @param parameters An instance of ServiceSelectorpreferences with properties set to customize text properties of the RAF
 */
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController WithRAFParameters:(ServiceSelectorPreferences*)parameters;

@end
