//
//  AMBNetworkManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkManager.h"
#import "AMBErrors.h"

@implementation AMBNetworkManager

static NSURLSession * urlSession;

+ (instancetype)sharedInstance {
    static AMBNetworkManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBNetworkManager alloc] init];
        urlSession = [_sharedInsance createURLSession];
    });
    
    return _sharedInsance;
}

- (NSMutableURLRequest *)urlRequestFor:(NSString *)url body:(NSData *)b requestType:(NSString*)requestType authorization:(NSString *)a additionalParameters:(NSMutableDictionary*)additParams {
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    r.HTTPMethod = requestType;
    [r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [r setValue:a forHTTPHeaderField:@"Authorization"];
    
    // Sets header values passed in with dictionary to additionParameters
    if (additParams || additParams.count > 0) {
        NSArray *keyArray = additParams.allKeys;
        
        for (int i = 0; i < additParams.count; i++) {
            [r setValue:[additParams valueForKey:keyArray[i]] forHTTPHeaderField:keyArray[i]];
        }
    }

    if (b) { r.HTTPBody = b; }

    return r;
}

- (void)dataTaskForRequest:(NSMutableURLRequest *)r session:(NSURLSession *)s completion:( void(^)(NSData *d, NSURLResponse *r, NSError *e))c {
    [[s dataTaskWithRequest:r completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
        NSError *e = (code >= 200 && code < 300)? nil : AMBBADRESPError(code, data);
        e = error? error : e;
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(data, response, e); }); }
    }] resume];
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
    
    [[urlSession dataTaskWithRequest:identifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"SEND IDENTIFY Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            if (success) { success([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"SEND IDENTIFY Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)sendShareTrackForServiceType:(AMBSocialServiceType)socialType contactList:(NSMutableArray*)contactList success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    AMBShareTrackNetworkObject *shareTrackObject = [[AMBShareTrackNetworkObject alloc] init];
    shareTrackObject.short_code = [AMBValues getUserURLObject].short_code;
    shareTrackObject.social_name = [AMBOptions serviceTypeStringValue:socialType];
    
    switch (socialType) {
        case AMBSocialServiceTypeSMS:
            shareTrackObject.recipient_username = contactList;
            break;
        case AMBSocialServiceTypeEmail:
            shareTrackObject.recipient_email = contactList;
            break;
        default:
            break;
    }
    
    NSMutableURLRequest *shareTrackRequest = [self createURLRequestWithURL:[AMBValues getShareTrackUrl] requestType:@"POST"];
    shareTrackRequest.HTTPBody = [shareTrackObject toData];
    
    [[urlSession dataTaskWithRequest:shareTrackRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"SHARE TRACK Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);; }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
        } else {
            DLog(@"SHARE TRACK Error - %@", error);
            if (failure) { failure([error localizedFailureReason]); }
        }
    }] resume];
}

- (void)getLinkedInRequestTokenWithKey:(NSString*)key success:(void(^)())success failure:(void(^)(NSString *error))failure {
    NSString *bodyValue = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=http://localhost:2999/&client_id=75sew7u54h2hn0&client_secret=pX72VGlgpjMnzTGs", key];
    
    NSMutableURLRequest *linkedinRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[AMBValues getLinkedInRequestTokenUrl]]];
    linkedinRequest.HTTPMethod = @"POST";
    [linkedinRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    linkedinRequest.HTTPBody = [bodyValue dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:linkedinRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            DLog(@"LINKEDIN REQUEST TOKEN Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
            if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
                NSMutableDictionary *tokenResponse = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                [AMBValues setLinkedInExpirationDate:tokenResponse[@"expires_in"]];
                [AMBValues setLinkedInAccessToken:tokenResponse[@"access_token"]];
                if (success) { success(); }
            } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]){
                if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
            } else {
                DLog(@"LINKEDIN REQUEST TOKEN Error - %@", error);
                if (failure) { failure([error localizedFailureReason]); }
            }
        }];
    }];
    
    [task resume];
}

- (void)checkForInvalidatedTokenWithCompletion:(void(^)())complete {
    NSURL *url = [NSURL URLWithString:[AMBValues getLinkedInValidationUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [AMBValues getLinkedInAccessToken]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (!error && ((NSHTTPURLResponse*)response).statusCode == 401) {
                DLog(@"Nullifying Linkedin Tokens");
                [AMBValues setLinkedInAccessToken:nil];
            } else if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
                DLog(@"LinkedIn Tokens are still up to date");
            } else {
                DLog(@"LINKEDIN TOKEN VALIDATION CHECK Error - %@", error);
            }
            
            complete();
        }];
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
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
                DLog(@"Linkedin Post SUCCESSFUL!");
                if (success) { success(); }
            } else if (!error && ((NSHTTPURLResponse*)response).statusCode == 401) {
                if (shouldReauthenticate) { shouldReauthenticate(); }
            } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
                DLog(@"Linkedin Post FAILED with response - %@", error);
                if (failure) { failure([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); }
            } else {
                DLog(@"LINKEDIN POST Error - %@", error);
                if (failure) { failure([error localizedFailureReason]); }
            }
        }];
    }];
    
    [task resume];
}

- (void)bulkShareSmsWithMessage:(NSString*)message phoneNumbers:(NSArray*)phoneNumbers success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSString *senderName = [NSString stringWithFormat:@"%@ %@", [AMBValues getUserFirstName], [AMBValues getUserLastName]];
    AMBBulkShareSMSObject *smsObject = [[AMBBulkShareSMSObject alloc] initWithPhoneNumbers:phoneNumbers fromSender:senderName message:message];
    NSMutableURLRequest *smsRequest = [self createURLRequestWithURL:[AMBValues getBulkShareSMSUrl] requestType:@"POST"];
    smsRequest.HTTPBody = [smsObject toData];
    
    [[urlSession dataTaskWithRequest:smsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    AMBBulkShareEmailObject *emailObject = [[AMBBulkShareEmailObject alloc] initWithEmails:addresses shortCode:[AMBValues getUserURLObject].short_code message:message subjectLine:[AMBValues getUserURLObject].subject];
    NSMutableURLRequest *emailRequest = [self createURLRequestWithURL:[AMBValues getBulkShareEmailUrl] requestType:@"POST"];
    emailRequest.HTTPBody = [emailObject toData];
    
    [[urlSession dataTaskWithRequest:emailRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
            DLog(@"Email Bulk Share SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*)response).statusCode]) {
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
    
    [[urlSession dataTaskWithRequest:nameUpdateRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"NAME UPDATE Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            DLog(@"Updating Names SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            [AMBValues setUserFirstNameWithString:firstName];
            [AMBValues setUserLastNameWithString:lastName];
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
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
    
    [[urlSession dataTaskWithRequest:conversionRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"SEND CONVERSION Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            DLog(@"Sending Conversion SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            DLog(@"Sending Conversion FAILED with response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failure) { failure(((NSHTTPURLResponse*) response).statusCode, data); }
        } else {
            DLog(@"SEND CONVERSION Error - %@", error);
            if (failure) { failure(((NSHTTPURLResponse*) response).statusCode, data); }
        }
    }] resume];
}

- (void)getPusherSessionWithSuccess:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure {
    NSMutableURLRequest *pusherRequest = [self createURLRequestWithURL:[AMBValues getPusherSessionUrl] requestType:@"POST"];
    [[urlSession dataTaskWithRequest:pusherRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"PUSHER SESSION Status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            DLog(@"Pusher Session SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
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
    
    [[urlSession dataTaskWithRequest:pusherUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        DLog(@"GET LARGE PUSH PAYLOAD status code = %i", (int)((NSHTTPURLResponse*) response).statusCode);
        if (!error && [AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
            DLog(@"Large Pusher Payload SUCCESSFUL with response - %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (success) { success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]); }
        } else if (!error && ![AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse*) response).statusCode]) {
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
