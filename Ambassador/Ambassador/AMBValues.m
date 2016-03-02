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

+ (BOOL)isProduction {
#if AMBPRODUCTION 
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)isUITestRun {
    return ([[[NSProcessInfo processInfo] arguments] containsObject:@"isUITesting"]);
}

#pragma mark - URLs

+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid {
    AMBPusherChannelObject *networkUrlObject = [AMBValues getPusherChannelObject];
    NSString *requestID = [AMBUtilities createRequestID];
    networkUrlObject.requestId = requestID;
    
    NSString *baseUrl;
    
    #if AMBPRODUCTION
        baseUrl = @"https://mbsy.co/universal/landing";
    #else
        baseUrl = @"https://staging.mbsy.co/universal/landing";
    #endif
    
    DLog(@"%@", [baseUrl stringByAppendingString:[NSString stringWithFormat:@"?url=%@://&universal_id=%@&mbsy_client_session_id=%@&mbsy_client_request_id=%@", @"ambassador:ios", uid, networkUrlObject.sessionId, requestID]]);
    
    return [baseUrl stringByAppendingString:[NSString stringWithFormat:@"?url=%@://&universal_id=%@&mbsy_client_session_id=%@&mbsy_client_request_id=%@", @"ambassador:ios", uid, networkUrlObject.sessionId, requestID]];
}

+ (NSString*)getSendIdentifyUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/universal/action/identify/" : @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/";
}

+ (NSString*)getShareTrackUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/track/share/" : @"https://dev-ambassador-api.herokuapp.com/track/share/";
}

+ (NSString*)getLinkedInAuthorizationUrl {
    return @"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=75sew7u54h2hn0&redirect_uri=http://localhost:2999/&state=987654321&scope=r_basicprofile%20w_share";
}

+ (NSString*)getLinkedInAuthCallbackUrl {
    return @"http://localhost:2999/";
}

+ (NSString*)getLinkedInRequestTokenUrl {
    return @"https://www.linkedin.com/uas/oauth2/accessToken";
}

+ (NSString*)getLinkedInValidationUrl {
    return @"https://api.linkedin.com/v1/people/~?format=json";
}

+ (NSString*)getLinkedInShareUrl {
    return @"https://api.linkedin.com/v1/people/~/shares?format=json";
}

+ (NSString*)getBulkShareSMSUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/share/sms/" : @"https://dev-ambassador-api.herokuapp.com/share/sms/";
}

+ (NSString*)getBulkShareEmailUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/share/email/" : @"https://dev-ambassador-api.herokuapp.com/share/email/";
}

+ (NSString*)getSendConversionUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/universal/action/conversion/" : @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/";
}

+ (NSString*)getPusherSessionUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/auth/session/" : @"https://dev-ambassador-api.herokuapp.com/auth/session/";
}

+ (NSString*)getPusherAuthUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/auth/subscribe/" : @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";
}

+ (NSString*)getSentryDSNValue {
    return @"https://648fb68f721d450e8ede94a914e5b4c6:9bc0f235f45c4a6aaa05dc709c4b6c4a@app.getsentry.com/67182";
}


#pragma mark - AMB Defaults

+ (NSUserDefaults*)ambUserDefaults {
    NSString *defaultsString = (NSClassFromString(@"XCTest")) ? @"AMBTEST" : @"AMBDEFAULTS";
    NSUserDefaults *ambDefaults = [[NSUserDefaults alloc] initWithSuiteName:defaultsString];
    return ambDefaults;
}


#pragma mark - Setter Methods

+ (void)setMbsyCookieWithCode:(NSString*)cookieCode {
    [[AMBValues ambUserDefaults] setValue:cookieCode forKey:@"mbsy_cookie_code"];
}

+ (void)setDeviceFingerPrintWithDictionary:(NSDictionary *)dictionary {
    [[AMBValues ambUserDefaults] setObject:dictionary forKey:@"device_fingerprint"];
}

+ (void)setHasInstalled {
    [[AMBValues ambUserDefaults] setValue:@YES forKey:@"AMBFIRSTLAUNCHSTORAGE"];
}

+ (void)setUniversalIDWithID:(NSString*)universalID {
    [[AMBValues ambUserDefaults] setValue:universalID forKey:@"universal_id"];
}

+ (void)setUniversalTokenWithToken:(NSString*)universalToken {
    [[AMBValues ambUserDefaults] setValue:universalToken forKey:@"universal_token"];
}

+ (void)setUserFirstNameWithString:(NSString*)firstName {
    [[AMBValues ambUserDefaults] setValue:[firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"first_name"];
}

+ (void)setUserLastNameWithString:(NSString*)lastName {
    [[AMBValues ambUserDefaults] setValue:[lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"last_name"];
}

+ (void)setLinkedInExpirationDate:(NSDate*)expirationDate {
    [[AMBValues ambUserDefaults] setValue:expirationDate forKey:@"lnkdin_expiration_date"];
}

+ (void)setLinkedInAccessToken:(NSString*)accessToken {
    [[AMBValues ambUserDefaults] setValue:accessToken forKey:@"lnkdin_access_token"];
}

+ (void)setUserEmail:(NSString*)email {
    [[AMBValues ambUserDefaults] setValue:email forKey:@"user_email"];
}

+ (void)setPusherChannelObject:(NSDictionary*)pusherChannel {
    [[AMBValues ambUserDefaults] setObject:pusherChannel forKey:@"pusher_channel_object"];
}

+ (void)setUserURLObject:(NSDictionary*)urlObject {
    [[AMBValues ambUserDefaults] setObject:urlObject forKey:@"user_url_object"];
}

+ (void)setAPNDeviceToken:(NSString*)deviceToken {
    [[AMBValues ambUserDefaults] setObject:deviceToken forKey:@"apn_device_token"];
}

// Should only be used for TESTING
+ (void)resetHasInstalled {
    NSUserDefaults *ambDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"AMBTEST"];
    [ambDefaults removeObjectForKey:@"AMBFIRSTLAUNCHSTORAGE"];
}

#pragma mark - Getter Methods

+ (NSString*)getMbsyCookieCode {
    return ([[AMBValues ambUserDefaults] valueForKey:@"mbsy_cookie_code"]) ? [[AMBValues ambUserDefaults] valueForKey:@"mbsy_cookie_code"] : @"";
}

+ (NSDictionary *)getDeviceFingerPrint {
    return ([[AMBValues ambUserDefaults] valueForKey:@"device_fingerprint"]) ? [[AMBValues ambUserDefaults] valueForKey:@"device_fingerprint"] : @{};
}

+ (BOOL)getHasInstalledBoolean {
    return ([[AMBValues ambUserDefaults] valueForKey:@"AMBFIRSTLAUNCHSTORAGE"]) ? (BOOL)[[AMBValues ambUserDefaults] valueForKey:@"AMBFIRSTLAUNCHSTORAGE"] : NO;
}

+ (NSString*)getUniversalID {
    return ([[AMBValues ambUserDefaults] valueForKey:@"universal_id"]) ? [[AMBValues ambUserDefaults] valueForKey:@"universal_id"] : @"";
}

+ (NSString*)getUniversalToken {
    return ([[AMBValues ambUserDefaults] valueForKey:@"universal_token"]) ? [[AMBValues ambUserDefaults] valueForKey:@"universal_token"] : @"";
}

+ (NSString*)getUserFirstName {
    return ([[AMBValues ambUserDefaults] valueForKey:@"first_name"]) ? [[AMBValues ambUserDefaults] valueForKey:@"first_name"] : @"";
}

+ (NSString*)getUserLastName {
    return ([[AMBValues ambUserDefaults] valueForKey:@"last_name"]) ? [[AMBValues ambUserDefaults] valueForKey:@"last_name"] : @"";
}

+ (NSDate*)getLinkedInTokenExirationDate {
    return [[AMBValues ambUserDefaults] valueForKey:@"lnkdin_expiration_date"];
}

+ (NSString*)getLinkedInAccessToken {
    return [[AMBValues ambUserDefaults] valueForKey:@"lnkdin_access_token"];
}

+ (NSString*)getUserEmail {
    return [[AMBValues ambUserDefaults] valueForKey:@"user_email"];
}

+ (AMBPusherChannelObject*)getPusherChannelObject {
    return [[AMBPusherChannelObject alloc] initWithDictionary:[[AMBValues ambUserDefaults] valueForKey:@"pusher_channel_object"]];
}

+ (AMBUserUrlNetworkObject*)getUserURLObject {
    return [[AMBUserUrlNetworkObject alloc] initWithDictionary:[[AMBValues ambUserDefaults] valueForKey:@"user_url_object"]];
}

+ (NSString*)getAPNDeviceToken {
    return [[AMBValues ambUserDefaults] valueForKey:@"apn_device_token"];
}

@end
