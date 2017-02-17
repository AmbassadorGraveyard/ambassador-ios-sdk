//
//  AMBNetworkManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkManager.h"
#import "AMBErrors.h"
#import "AMBBulkShareHelper.h"

@implementation AMBNetworkManager


#pragma mark - Shared Instance

+ (instancetype)sharedInstance {
    static AMBNetworkManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBNetworkManager alloc] init];
        _sharedInsance.urlSession = [_sharedInsance createURLSession];
    });
    
    return _sharedInsance;
}


#pragma mark - Network Calls 

- (void)sendIdentifyForCampaign:(NSString*)campaign shouldEnroll:(BOOL)enroll success:(void(^)(NSString *response))success failure:(void(^)(NSString *error))failure {
    AMBIdentifyNetworkObject *identifyObject = [AMBValues getUserIdentifyObject];
    identifyObject.campaign_id = campaign;
    identifyObject.enroll = enroll;
    identifyObject.fp = [AMBValues getDeviceFingerPrint];
    
    NSMutableURLRequest *identifyRequest = [self createURLRequestWithURL:[AMBValues getSendIdentifyUrl] requestType:@"POST"];
    [identifyRequest setValue:[AMBValues getPusherChannelObject].sessionId forHTTPHeaderField:@"X-Mbsy-Client-Session-ID"];
    [identifyRequest setValue:[AMBValues getPusherChannelObject].requestId forHTTPHeaderField:@"X-Mbsy-Client-Request-ID"];
    identifyRequest.HTTPBody = [identifyObject toData];
    
    [[self.urlSession dataTaskWithRequest:identifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = (int)((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (success) { success([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"[Identify] Send Identify Error - %li %@", (long)statusCode, error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)sendShareTrackForServiceType:(AMBSocialServiceType)socialType contactList:(NSMutableArray*)contactList success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *shareTrackRequest = [self createURLRequestWithURL:[AMBValues getShareTrackUrl] requestType:@"POST"];
    shareTrackRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:[AMBBulkShareHelper shareTrackPayload:contactList shareType:socialType] options:0 error:nil];
    
    [[self.urlSession dataTaskWithRequest:shareTrackRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = (int)((NSHTTPURLResponse*) response).statusCode;
        DLog(@"SHARE TRACK Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);; }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"SHARE TRACK Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)bulkShareSmsWithMessage:(NSString*)message phoneNumbers:(NSArray*)phoneNumbers success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSString *senderName = [NSString stringWithFormat:@"%@ %@", [AMBValues getUserFirstName], [AMBValues getUserLastName]];
    AMBBulkShareSMSObject *smsObject = [[AMBBulkShareSMSObject alloc] initWithPhoneNumbers:phoneNumbers fromSender:senderName message:message];
    NSMutableURLRequest *smsRequest = [self createURLRequestWithURL:[AMBValues getBulkShareSMSUrl] requestType:@"POST"];
    smsRequest.HTTPBody = [smsObject toData];
    
    [[self.urlSession dataTaskWithRequest:smsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
            DLog(@"SMS Bulk Share SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
            DLog(@"SMS Bulk Share FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"SMS BULK SHARE Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)bulkShareEmailWithMessage:(NSString*)message emailAddresses:(NSArray*)addresses success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    AMBBulkShareEmailObject *emailObject = [[AMBBulkShareEmailObject alloc] initWithEmails:addresses message:message];
    NSMutableURLRequest *emailRequest = [self createURLRequestWithURL:[AMBValues getBulkShareEmailUrl] requestType:@"POST"];
    emailRequest.HTTPBody = [emailObject toData];
    
    [[self.urlSession dataTaskWithRequest:emailRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Email Bulk Share SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Email Bulk Share FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"EMAIL BULK SHARE Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)updateNameWithFirstName:(NSString*)firstName lastName:(NSString*)lastName success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    AMBUpdateNameObject *nameUpdateObject = [[AMBUpdateNameObject alloc] initWithFirstName:firstName lastName:lastName email:[AMBValues getUserEmail]];
    NSMutableURLRequest *nameUpdateRequest = [self createURLRequestWithURL:[AMBValues getSendIdentifyUrl] requestType:@"POST"];
    nameUpdateRequest.HTTPBody = [nameUpdateObject toData];
    
    [[self.urlSession dataTaskWithRequest:nameUpdateRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"NAME UPDATE Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Updating Names SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            [AMBValues setUserFirstNameWithString:firstName];
            [AMBValues setUserLastNameWithString:lastName];
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Updating Names FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"NAME UPDATE Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)updateAPNDeviceToken:(NSString*)deviceToken success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    AMBUpdateAPNTokenObject *apnTokenUpdateObject = [[AMBUpdateAPNTokenObject alloc] initWithAPNDeviceToken:deviceToken];
    NSMutableURLRequest *apnUpdateRequest = [self createURLRequestWithURL:[AMBValues getSendIdentifyUrl] requestType:@"POST"];
    apnUpdateRequest.HTTPBody = [apnTokenUpdateObject toData];
    
    [[self.urlSession dataTaskWithRequest:apnUpdateRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"APN TOKEN UPDATE Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Updating APN Token SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Updating APN Token FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"APN TOKEN UPDATE Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)sendRegisteredConversion:(NSDictionary*)conversionDict success:(void(^)(NSDictionary *response))success failure:(void(^)(NSInteger statusCode, NSData *data))failure {
    NSMutableURLRequest *conversionRequest = [self createURLRequestWithURL:[AMBValues getSendConversionUrl] requestType:@"POST"];
    conversionRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:conversionDict options:0 error:nil];
    
    [[self.urlSession dataTaskWithRequest:conversionRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Sending Conversion FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure(statusCode, data); }
        } else {
            DLog(@"SEND CONVERSION Error - %@", error);
            if (failure) { failure(statusCode, data); }
        }
    }] resume];
}

- (void)getPusherSessionWithSuccess:(void(^)(NSDictionary *response))success noSDKAccess:(void(^)())noSDKAccess failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *pusherRequest = [self createURLRequestWithURL:[AMBValues getPusherSessionUrl] requestType:@"POST"];
    [[self.urlSession dataTaskWithRequest:pusherRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && statusCode == 401) {
            DLog(@"NO access to SDK");
            if (noSDKAccess) { noSDKAccess(); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Pusher Session FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"PUSHER SESSION Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)getLargePusherPayloadFromUrl:(NSString*)url success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *pusherUrlRequest = [self createURLRequestWithURL:url requestType:@"GET"];
    [[self.urlSession dataTaskWithRequest:pusherUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"GET LARGE PUSH PAYLOAD status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Large Pusher Payload SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Large Pusher Payload FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"GET LARGE PUSHER PAYLOAD Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}


#pragma mark - LinkedIn Requests

- (void)getCompanyUIDWithSuccess:(void(^)(NSString *companyUID))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *companyUrlRequest = [self createURLRequestWithURL:[AMBValues getCompanyDetailsUrl] requestType:@"GET"];
    [[self.urlSession dataTaskWithRequest:companyUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"GET COMPANY DETAILS PAYLOAD status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            DLog(@"Company Details SUCCESSFUL with response - %@", returnDict);
            if (success) { success([NSString stringWithFormat:@"%@", returnDict[@"results"][0][@"uid"]]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Company Details FAILED with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"Get Company Details Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)getLinkedInClientValuesWithUID:(NSString*)companyUID success:(void(^)(NSDictionary *clientValues))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *linkedinClientRequest = [self createURLRequestWithURL:[AMBValues getLinkedinClientValuesUrl:companyUID] requestType:@"GET"];
    [[self.urlSession dataTaskWithRequest:linkedinClientRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"GET LINKEDIN CLIENT PAYLOAD status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            DLog(@"LinkedIn Client SUCCESSFUL with response - %@", returnDict);
            [AMBValues setLinkedInClientID:returnDict[@"envoy_client_id"]];
            [AMBValues setLinkedInClientSecret:returnDict[@"envoy_client_secret"]];
            if (success) { success(returnDict); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"LinkedIn Client FAILED with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"Get LinkedIn Client Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)getLinkedInAccessTokenWithPopupValue:(NSString*)popupValue success:(void(^)(NSString *accessToken))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *linkedinAccessRequest = [self createURLRequestWithURL:[AMBValues getLinkedinAccessTokenUrl:popupValue] requestType:@"GET"];

    [[self.urlSession dataTaskWithRequest:linkedinAccessRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"GET LINKEDIN ACCESS TOKEN status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            DLog(@"LinkedIn Access Token SUCCESSFUL with response - %@", returnDict);
            [AMBValues setLinkedInAccessToken:returnDict[@"access_token"]];
            if (success) { success(returnDict[@"access_token"]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"LinkedIn Access Token FAILED with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"Get LinkedIn Access Token Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)shareToLinkedInWithMessage:(NSString*)message success:(void(^)(NSString *successMessage))success failure:(void(^)(NSString *error))failure {
    // Encodes the url because of the spaces in the message
    NSString *encodedUrl = [[AMBValues getLinkedInShareUrlWithMessage:message] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *linkedInShareRequest = [self createURLRequestWithURL:encodedUrl requestType:@"GET"];
    [[self.urlSession dataTaskWithRequest:linkedInShareRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"LINKEDIN SHARE status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"Linkedin Share SUCCESSFUL with response - %@", returnString);
            if (success) { success(returnString); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"LinkedIn Share FAILED with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"LinkedIn Share Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}


- (NSData *)getUrlInformationWithSuccess:(NSString*)shortCode {
    // Encodes the url
    NSString *encodedUrl = [[AMBValues getUrlInformationUrl:shortCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [self createURLRequestWithURL:encodedUrl requestType:@"GET"];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", encodedUrl, (long)[responseCode statusCode]);
        return oResponseData;
    }
    
    return oResponseData;
    
}


#pragma mark - Welcome Screen Requests

- (void)getReferrerInformationWithSuccess:(void(^)(NSDictionary *referrerInfo))success failure:(void(^)(NSString *error))failure {
    NSDictionary *payloadDict = @{@"short_code" : [AMBValues getMbsyCookieCode]};
    NSMutableURLRequest *referrerRequest = [self createURLRequestWithURL:[AMBValues getReferrerInformationUrl] requestType:@"POST"];
    referrerRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
    
    [[self.urlSession dataTaskWithRequest:referrerRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"REFERRER INFO status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSDictionary *referrerInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            DLog(@"Referrer Info SUCCESSFUL with response - %@", referrerInfo);
            if (success) { success(referrerInfo); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Referrer Info FAILED with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"Referrer Info Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}


#pragma mark - Helper Functions

- (NSURLSession*)createURLSession {
    return ([AMBValues isProduction]) ? [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] :
        [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

- (NSMutableURLRequest*)createURLRequestWithURL:(NSString*)urlString requestType:(NSString*)requestType {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = requestType;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[AMBValues getUniversalToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:[AMBValues getUniversalID] forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    
    return request;
}


#pragma mark - NSURLSession Delegate

// Allows certain requests to be made for dev servers when running in unit tests for Circle
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if([challenge.protectionSpace.host isEqualToString:@"dev-ambassador-api.herokuapp.com"] || [challenge.protectionSpace.host isEqualToString:@"dev-envoy-api.herokuapp.com"]) { // Makes sure that it's our url being challenged
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
