//
//  Ambassador.h
//  Copyright (c) 2015 ZFERRAL INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMBConversionFieldsNetworkObject.h"
#import "AMBServiceSelectorPreferences.h"

/**
 `Ambassador` is the object that provides access to Ambassador's SDK functionality
 
 Subclassing Notes
 This class is provided as an easy way to integrate Ambassador's services in your iOS app and is not intended to be subclassed. Subclassing may lead to unexpected behavior and stability issues.
 
 Methods to override
 No methods should be overridden. This class is not meant to be subclassed.
 */

@interface AmbassadorSDK : NSObject
+ (void)ambassadorWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID;

+ (void)identify:(NSString *)email completion:(void(^)(NSError *))completion;

+ (void)conversion:(AMBConversionFieldsNetworkObject *)fields completion:(void(^)(NSError *))completion;

+ (void)sendConversions:(NSString *)universalToken universalID:(NSString *)universalID completion:(void(^)(NSError*))completion;

@end
