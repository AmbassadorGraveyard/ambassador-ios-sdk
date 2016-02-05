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
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] init];
    identifyObject.email = [AMBValues getUserEmail];
    identifyObject.campaign_id = campaign;
    identifyObject.enroll = enroll;
    identifyObject.fp = [AMBValues getDeviceFingerPrint];
    
    NSMutableURLRequest *identifyRequest = [self createURLRequestWithURL:[AMBValues getSendIdentifyUrl] requestType:@"POST"];
    [identifyRequest setValue:[AMBValues getPusherChannelObject].sessionId forHTTPHeaderField:@"X-Mbsy-Client-Session-ID"];
    [identifyRequest setValue:[AMBValues getPusherChannelObject].requestId forHTTPHeaderField:@"X-Mbsy-Client-Request-ID"];
    identifyRequest.HTTPBody = [identifyObject toData];
    
    [[self.urlSession dataTaskWithRequest:identifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = (int)((NSHTTPURLResponse*) response).statusCode;
        DLog(@"SEND IDENTIFY Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (success) { success([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"SEND IDENTIFY Error - %@", error);
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

- (void)getLinkedInRequestTokenWithKey:(NSString*)key success:(void(^)())success failure:(void(^)(NSString *error))failure {
    NSString *bodyValue = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=http://localhost:2999/&client_id=***REMOVED***&client_secret=***REMOVED***", key];
    
    NSMutableURLRequest *linkedinRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[AMBValues getLinkedInRequestTokenUrl]]];
    linkedinRequest.HTTPMethod = @"POST";
    [linkedinRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    linkedinRequest.HTTPBody = [bodyValue dataUsingEncoding:NSUTF8StringEncoding];
    
     NSURLSession *mainQueueSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [mainQueueSession dataTaskWithRequest:linkedinRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"LINKEDIN REQUEST TOKEN Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSMutableDictionary *tokenResponse = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            [AMBValues setLinkedInExpirationDate:tokenResponse[@"expires_in"]];
            [AMBValues setLinkedInAccessToken:tokenResponse[@"access_token"]];
            if (success) { success(); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]){
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"LINKEDIN REQUEST TOKEN Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }];
    
    [task resume];
}

- (void)checkForInvalidatedTokenWithCompletion:(void(^)())complete {
    NSURL *url = [NSURL URLWithString:[AMBValues getLinkedInValidationUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [AMBValues getLinkedInAccessToken]] forHTTPHeaderField:@"Authorization"];
    
     NSURLSession *mainQueueSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task = [mainQueueSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
        if (!error && statusCode == 401) {
            DLog(@"Nullifying Linkedin Tokens");
            [AMBValues setLinkedInAccessToken:nil];
        } else if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"LinkedIn Tokens are still up to date");
        } else {
            DLog(@"LINKEDIN TOKEN VALIDATION CHECK Error - %@", error);
        }
        
        complete();
    }];
    
    [task resume];
}

- (void)shareToLinkedinWithPayload:(NSDictionary*)payload success:(void(^)())success needsReauthentication:(void(^)())shouldReauthenticate failure:(void(^)(NSString *error))failure {
    NSURL *url = [NSURL URLWithString:[AMBValues getLinkedInShareUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [AMBValues getLinkedInAccessToken]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    NSURLSession *mainQueueSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [mainQueueSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Linkedin Post SUCCESSFUL!");
            if (success) { success(); }
        } else if (!error && statusCode == 401) {
            if (shouldReauthenticate) { shouldReauthenticate(); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Linkedin Post FAILED with response - %@", error);
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"LINKEDIN POST Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }];
    
    [task resume];
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

- (void)sendRegisteredConversion:(NSDictionary*)conversionDict success:(void(^)(NSDictionary *response))success failure:(void(^)(NSInteger statusCode, NSData *data))failure {
    NSMutableURLRequest *conversionRequest = [self createURLRequestWithURL:[AMBValues getSendConversionUrl] requestType:@"POST"];
    conversionRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:conversionDict options:0 error:nil];
    
    [[self.urlSession dataTaskWithRequest:conversionRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"SEND CONVERSION Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Sending Conversion SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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

- (void)getPusherSessionWithSuccess:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *pusherRequest = [self createURLRequestWithURL:[AMBValues getPusherSessionUrl] requestType:@"POST"];
    [[self.urlSession dataTaskWithRequest:pusherRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        DLog(@"PUSHER SESSION Status code = %li", (long)statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            DLog(@"Pusher Session SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
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
        if([challenge.protectionSpace.host isEqualToString:@"dev-ambassador-api.herokuapp.com"]) { // Makes sure that it's our url being challenged
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
