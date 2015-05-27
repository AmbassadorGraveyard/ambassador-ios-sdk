//
//  AMBASSADORConstants.m
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Augur Variables
NSString *const augurFingerprintURL = @"http://127.0.0.1:7999/augur.html?cbURL=myapp:mylocation";
NSString *const JSONJavascriptVariableName = @"JSONdata";

#pragma mark - Identify Status Messages
NSString *const JSONParseErrorMessage = @"Unable to parse JSON reponse";
NSString *const JSONCompletedNotificationName = @"AMBFingerprintDidGetJSON";
NSString *const fingerprintSuccessMessage = @"Sucessful fingerprint";
NSString *const fingerprintErrorMessage = @"Non successful fingerprint";
NSString *const webViewFailedToLoadErrorMessage = @"webView failed to load";
NSString *const noConversionEmailDefualtString = @"-1";

#pragma mark - Identify Funcitons' Variables
NSString *const internalURLString = @"myapp";
NSString *const NSUserDefaultsKeyName = @"AmbassadorReturnedJSON";

#pragma mark - Errors
NSString *const conversionErrorDomain = @"com.Ambassador.Conversion.ErrorDomain";

enum {
    ConversionBadResponse,
    ConversionFailureToLoad
};