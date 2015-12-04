//
//  AMBValues.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/28/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBValues.h"
#import "AMBPusherChannelObject.h"
#import "AMBUtilities.h"
#import "AmbassadorSDK_Internal.h"

@implementation AMBValues


#pragma mark - Images

+ (UIImage*)imageFromBundleWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 8.0) {
        return [AMBValues imageFromAssetsWithName:name tintable:tintable];
    } else {
        return [AMBValues imageFromBundleWithName:name type:type tintable:tintable];
    }
}

// FOR IOS 8 AND ABOVE **
+ (UIImage*)imageFromAssetsWithName:(NSString*)name tintable:(BOOL)tintable {
    NSBundle *ambassadorBundle = ([NSBundle bundleWithIdentifier:@"AmbassadorBundle"]) ? [NSBundle bundleWithIdentifier:@"AmbassadorBundle"] : [NSBundle bundleForClass:[self class]];
    
    if (tintable) {
        return [[UIImage imageNamed:name inBundle:ambassadorBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        return [UIImage imageNamed:name inBundle:ambassadorBundle compatibleWithTraitCollection:nil];
    }
}

// FOR IOS 7 **
+ (UIImage*)imageFromResourcesWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable {
    if (tintable) {
        return [[UIImage imageWithContentsOfFile:[[AMBValues AMBframeworkBundle] pathForResource:name ofType:type]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        return [UIImage imageWithContentsOfFile:[[AMBValues AMBframeworkBundle] pathForResource:name ofType:type]];
    }
}

+ (NSBundle*)AMBframeworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Ambassador.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    
    return (frameworkBundle) ? frameworkBundle : [NSBundle bundleForClass:[self class]]; // This returns the framework bundle, but if unit testing, it will return the unit test's bundle
}


#pragma mark - URLs

+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid {
    AMBPusherChannelObject *networkUrlObject = [AmbassadorSDK sharedInstance].pusherChannelObj;
    NSString *requestID = [AMBUtilities createRequestID];
    [AmbassadorSDK sharedInstance].pusherChannelObj.requestId = requestID;
    
    NSString *baseUrl;
    
    #if AMBPRODUCTION
        baseUrl = @"https://mbsy.co/universal/landing";
    #else
        baseUrl = @"https://staging.mbsy.co/universal/landing";
    #endif
    
    DLog(@"%@", [baseUrl stringByAppendingString:[NSString stringWithFormat:@"?url=%@://&universal_id=%@&mbsy_client_session_id=%@&mbsy_client_request_id=%@", [AMBValues getDeepLinkURL], uid, networkUrlObject.sessionId, requestID]]);
    
    return [baseUrl stringByAppendingString:[NSString stringWithFormat:@"?url=%@://&universal_id=%@&mbsy_client_session_id=%@&mbsy_client_request_id=%@", [AMBValues getDeepLinkURL], uid, networkUrlObject.sessionId, requestID]];
}


#pragma mark - AMB Defaults

+ (NSUserDefaults*)ambUserDefaults {
    NSUserDefaults *ambDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"AMBDEFAULTS"];
    return ambDefaults;
}

+ (void)clearAmbUserDefaults {
    [[AMBValues ambUserDefaults] setValue:nil forKey:@"mbsy_cookie_code"];
}


#pragma mark - Setter Methods

+ (void)setMbsyCookieWithCode:(NSString*)cookieCode {
    [[AMBValues ambUserDefaults] setValue:cookieCode forKey:@"mbsy_cookie_code"];
}

+ (void)setDeviceFingerPrintWithDictionary:(NSDictionary *)dictionary {
    [[AMBValues ambUserDefaults] setObject:dictionary forKey:@"device_fingerprint"];
}

+ (void)setUserFirstNameWithString:(NSString*)firstName {
    [[AMBValues ambUserDefaults] setValue:[firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"first_name"];
}

+ (void)setUserLastNameWithString:(NSString*)lastName {
    [[AMBValues ambUserDefaults] setValue:[lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"last_name"];
}


#pragma mark - Getter Methods

+ (NSString*)getMbsyCookieCode {
    return ([[AMBValues ambUserDefaults] valueForKey:@"mbsy_cookie_code"]) ? [[AMBValues ambUserDefaults] valueForKey:@"mbsy_cookie_code"] : @"";
}

+ (NSDictionary *)getDeviceFingerPrint {
    return ([[AMBValues ambUserDefaults] valueForKey:@"device_fingerprint"]) ? [[AMBValues ambUserDefaults] valueForKey:@"device_fingerprint"] : @{};
}

+ (NSString*)getDeepLinkURL {
    NSArray *urlArray = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"]];
    NSDictionary *urlSchemeDict = [urlArray objectAtIndex:0];
    NSString *scheme = [urlSchemeDict valueForKey:@"CFBundleURLSchemes"][0];
    
    return scheme;
}

+ (NSString*)getUserFirstName {
    return ([[AMBValues ambUserDefaults] valueForKey:@"first_name"]) ? [[AMBValues ambUserDefaults] valueForKey:@"first_name"] : @"";
}

+ (NSString*)getUserLastName {
    return ([[AMBValues ambUserDefaults] valueForKey:@"last_name"]) ? [[AMBValues ambUserDefaults] valueForKey:@"last_name"] : @"";
}

@end
