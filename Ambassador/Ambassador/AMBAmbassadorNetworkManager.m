//
//  AMBAmbassadorNetworkManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBAmbassadorNetworkManager.h"
#import "AMBErrors.h"
#import "AmbassadorSDK_Internal.h"

@implementation AMBAmbassadorNetworkManager
+ (instancetype)sharedInstance {
    static AMBAmbassadorNetworkManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBAmbassadorNetworkManager alloc] init];
    });
    return _sharedInsance;
}

- (void)sendNetworkObject:(AMBNetworkObject *)o url:(NSString *)u additionParams:(NSMutableDictionary*)additionalParams requestType:(NSString*)requestType completion:(void (^)(NSData *, NSURLResponse *, NSError *))c {
    NSError *e;
    NSData *b = o? [o toDataError:&e] : nil;
    if (e) {
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, nil, e); }); }
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session;
#if AMBPRODUCTION
    session = [NSURLSession sharedSession];
#else
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];
#endif
    

    [[AMBAmbassadorNetworkManager sharedInstance] dataTaskForRequest:[[AMBAmbassadorNetworkManager sharedInstance] urlRequestFor:u body:b requestType:requestType authorization:[AmbassadorSDK sharedInstance].universalToken additionalParameters:additionalParams] session:session completion:c];
}

- (void)pusherChannelNameUniversalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *e))c {
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:[AMBAmbassadorNetworkManager pusherSessionSubscribeUrl] additionParams:nil requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) {
            dispatch_async(dispatch_get_main_queue(), ^{ c(nil, nil, e); });
        } else {
            NSMutableDictionary *payloadDict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&e];
            dispatch_async(dispatch_get_main_queue(), ^{ c(payloadDict[@"channel_name"], payloadDict, e); });
        }
    }];
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"dev-ambassador-api.herokuapp.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

+ (NSString *)baseUrl {
#if AMBPRODUCTION
    return @"https://api.getambassador.com/";
# else
    return @"https://dev-ambassador-api.herokuapp.com/";
#endif
//
//    if (YES) {
//         return @"https://dev-ambassador-api.herokuapp.com/";
//    }
//    return @"https://api.getambassador.com/universal/";
}

+ (NSString *)pusherAuthSubscribeUrl {
    return [NSString stringWithFormat:@"%@auth/subscribe/", [AMBAmbassadorNetworkManager baseUrl]];
}

+ (NSString *)pusherSessionSubscribeUrl {
    return [NSString stringWithFormat:@"%@auth/session/", [AMBAmbassadorNetworkManager baseUrl]];
}

+ (NSString *)sendIdentifyUrl {
    return [NSString stringWithFormat:@"%@universal/action/identify/", [AMBAmbassadorNetworkManager baseUrl]];
}

+ (NSString *)sendShareTrackUrl {
    return [NSString stringWithFormat:@"%@track/share/", [AMBAmbassadorNetworkManager baseUrl]];
}

+ (NSString *)bulkShareEmailUrl {
    return [NSString stringWithFormat:@"%@share/email/", [AMBAmbassadorNetworkManager baseUrl]];
}

+ (NSString *)bulkShareSMSUrl {
    return [NSString stringWithFormat:@"%@share/sms/", [AMBAmbassadorNetworkManager baseUrl]];
}

@end
