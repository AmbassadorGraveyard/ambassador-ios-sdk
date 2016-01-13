//
//  Ambassador.h
//  Copyright (c) 2015 ZFERRAL INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMBConversionParameters.h"

/**
 `Ambassador` is the object that provides access to Ambassador's SDK functionality
 
 Subclassing Notes
 This class is provided as an easy way to integrate Ambassador's services in your iOS app and is not intended to be subclassed. Subclassing may lead to unexpected behavior and stability issues.
 
 Methods to override
 No methods should be overridden. This class is not meant to be subclassed.
 */

@interface AmbassadorSDK : NSObject

/**Initializes Ambassador in an application using the provided credentials*/
+ (void)runWithUniversalToken:(NSString *)UniversalToken universalID:(NSString *)universalID;

/**Identifies a user and associates it with the given email*/
+ (void)identifyWithEmail:(NSString *)email;

/**Registers a conversion with Ambassador using the properties set in 'conversionParameters'*/
+ (void)registerConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(NSError *error))completion;

/**Presents a full-page modal 'Refer-A-Friend' (RAF) ViewController*/
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController;


@end
