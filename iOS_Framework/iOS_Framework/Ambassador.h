//
//  Ambassador.h
//  Copyright (c) 2015 ZFERRAL INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConversionParameters.h"
#import "ServiceSelectorPreferences.h"

/**
 `Ambassador` is the object that provides access to Ambassador's SDK functionality
 
 ## Subclaasing Notes
 This class is provided as an easy way to integrate Ambassador's services in your iOS app and is not intended to be subclassed. Subclassing may lead to unexpected behavior and stability issues.
 
 ## Methods to override
 No methods should be overridden. This class is not meant to be subclassed.
 */

@interface Ambassador : NSObject

#pragma mark - API functions
+ (void)runWithKey:(NSString *)key convertOnInstall:(ConversionParameters *)information;
+ (void)registerConversion:(ConversionParameters *)information;
+ (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController WithRAFParameters:(ServiceSelectorPreferences*)parameters;
+ (void)identifyWithEmail:(NSString *)email;

@end

