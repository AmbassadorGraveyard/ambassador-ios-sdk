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
#import "AMBSecrets.h"

@implementation AMBValues

NSString * TEST_APP_CONTSTANT = @"AMBTESTAPP";


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
    // Creates a unique value that will be used to match up and get Linkedin access token from Envoy
    NSString *popupvalue = [NSString stringWithFormat:@"%@%@%@", [AMBValues getLinkedInClientID], [AMBUtilities createRequestID], [AMBUtilities create32CharCode]];
    return [AMBValues isProduction] ? [NSString stringWithFormat:@"https://api.getenvoy.co/oauth/authenticate/?client_id=%@&client_secret=%@&provider=linkedin&popup=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], popupvalue] :
        [NSString stringWithFormat:@"https://dev-envoy-api.herokuapp.com/oauth/authenticate/?client_id=%@&client_secret=%@&provider=linkedin&popup=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], popupvalue];
}

+ (NSString*)getLinkedInShareUrlWithMessage:(NSString*)message {
    return [AMBValues isProduction] ? [NSString stringWithFormat:@"https://api.getenvoy.co/provider/linkedin/share/?client_id=%@&client_secret=%@&access_token=%@&message=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], [AMBValues getLinkedInAccessToken], message] :
        [NSString stringWithFormat:@"https://dev-envoy-api.herokuapp.com/provider/linkedin/share/?client_id=%@&client_secret=%@&access_token=%@&message=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], [AMBValues getLinkedInAccessToken], message];
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
    return [NSString stringWithFormat:@"https://%@@app.getsentry.com/67182", [AMBSecrets secretForKey:AMB_SENTRY_KEY]];
}

+ (NSString*)getCompanyDetailsUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/companies/" : @"https://dev-ambassador-api.herokuapp.com/companies/";
}

+ (NSString*)getLinkedinClientValuesUrl:(NSString*)clientUID {
    return [AMBValues isProduction] ? [NSString stringWithFormat:@"https://api.getambassador.com/companies/%@/", clientUID] : [NSString stringWithFormat:@"https://dev-ambassador-api.herokuapp.com/companies/%@/", clientUID];
}

+ (NSString*)getLinkedinAccessTokenUrl:(NSString*)popupValue {
    return [AMBValues isProduction] ? [NSString stringWithFormat:@"https://api.getenvoy.co/oauth/access_token/?client_id=%@&client_secret=%@&popup=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], popupValue] :
        [NSString stringWithFormat:@"https://dev-envoy-api.herokuapp.com/oauth/access_token/?client_id=%@&client_secret=%@&popup=%@", [AMBValues getLinkedInClientID], [AMBValues getLinkedInClientSecret], popupValue];
}

+ (NSString*)getReferrerInformationUrl {
    return [AMBValues isProduction] ? @"https://api.getambassador.com/ambassadors/profile/" : @"https://dev-ambassador-api.herokuapp.com/ambassadors/profile/";
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
    [[AMBValues ambUserDefaults] setValue:accessToken forKey:@"envoy_access_token"];
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

+ (void)setUserCampaignList:(AMBUserNetworkObject *)userObject {
    // Encodes object to data in order to save to defaults
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:userObject];
    [[AMBValues ambUserDefaults] setObject:encodedObject forKey:@"amb_user_object"];
}

+ (void)setAPNDeviceToken:(NSString*)deviceToken {
    [[AMBValues ambUserDefaults] setObject:deviceToken forKey:@"apn_device_token"];
}

+ (void)setLinkedInClientID:(NSString*)clientID {
    [[AMBValues ambUserDefaults] setObject:clientID forKey:@"linkedin_client_id"];
}

+ (void)setLinkedInClientSecret:(NSString*)clientSecret {
    [[AMBValues ambUserDefaults] setObject:clientSecret forKey:@"linkedin_client_secret"];
}

+ (void)setUserIdentifyObject:(AMBIdentifyNetworkObject *)identifyObject {
    // Encodes object to data in order to save to defaults
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:identifyObject];
    [[AMBValues ambUserDefaults] setObject:encodedObject forKey:@"user_identify_object"];
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
    return [[AMBValues ambUserDefaults] valueForKey:@"envoy_access_token"];
}

+ (NSString*)getUserEmail {
    // If the deprecated version of identify is used 'identifyWithEmail
    if ([[AMBValues ambUserDefaults] valueForKey:@"user_email"]) {
        return [[AMBValues ambUserDefaults] valueForKey:@"user_email"];
    
    // If the new version of identify is used 'identifyWithUserID
    } else if ([AMBValues getUserIdentifyObject].email) {
        return [AMBValues getUserIdentifyObject].email;
        
    // If identify has not yet been called
    } else {
        return nil;
    }
}

+ (AMBPusherChannelObject*)getPusherChannelObject {
    return (![[[AMBValues ambUserDefaults] valueForKey:@"pusher_channel_object"] isEqual: @{}]) ? [[AMBPusherChannelObject alloc] initWithDictionary:[[AMBValues ambUserDefaults] valueForKey:@"pusher_channel_object"]] : nil;
}

+ (AMBUserUrlNetworkObject*)getUserURLObject {
    return [[AMBUserUrlNetworkObject alloc] initWithDictionary:[[AMBValues ambUserDefaults] valueForKey:@"user_url_object"]];
}

+ (AMBUserNetworkObject *)getUserCampaignList {
    // Grabs data from defaults and creates object from it
    NSData *encodedObject = [[AMBValues ambUserDefaults] valueForKey:@"amb_user_object"];
    AMBUserNetworkObject *returnUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return returnUser;
}

+ (NSString*)getAPNDeviceToken {
    return [[AMBValues ambUserDefaults] valueForKey:@"apn_device_token"];
}

+ (NSString*)getLinkedInClientID {
    return [[AMBValues ambUserDefaults] valueForKey:@"linkedin_client_id"];
}

+ (NSString*)getLinkedInClientSecret {
    return [[AMBValues ambUserDefaults] valueForKey:@"linkedin_client_secret"];
}

+ (AMBIdentifyNetworkObject *)getUserIdentifyObject {
    // Grabs the encoded identify object's data from user defaults
    NSData *encodedObject = [[AMBValues ambUserDefaults] valueForKey:@"user_identify_object"];
    AMBIdentifyNetworkObject *identifyObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return identifyObject;
}

@end
