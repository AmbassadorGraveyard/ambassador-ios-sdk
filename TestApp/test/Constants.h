//
//  Constants.h
//  Ambassador
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Augur Variables
FOUNDATION_EXPORT NSString *const augurFingerprintURL;
FOUNDATION_EXPORT NSString *const JSONJavascriptVariableName;

#pragma mark - Identify Status Messages
FOUNDATION_EXPORT NSString *const JSONParseErrorMessage;
FOUNDATION_EXPORT NSString *const JSONCompletedNotificationName;
FOUNDATION_EXPORT NSString *const fingerprintSuccessMessage;
FOUNDATION_EXPORT NSString *const fingerprintErrorMessage;
FOUNDATION_EXPORT NSString *const webViewFailedToLoadErrorMessage;

#pragma mark - Identify Funcitons' Variables
FOUNDATION_EXPORT NSString *const internalURLString;
FOUNDATION_EXPORT NSString *const NSUserDefaultsKeyName;
FOUNDATION_EXPORT NSString *const noConversionEmailDefualtString;

#pragma mark - Errors
FOUNDATION_EXPORT NSString *const conversionErrorDomain;


#pragma mark - Welcome Screen Style Options
FOUNDATION_EXPORT NSString *const welcomeViewBackgroundColor;
FOUNDATION_EXPORT NSString *const welcomeViewTextColor;
FOUNDATION_EXPORT NSString *const welcomeViewTextFont;
FOUNDATION_EXPORT NSString *const welcomeViewButtonLableText;

@end
