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
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBAmbassadorNetworkManager alloc] init]; });
    return _sharedInsance;
}

- (void)sendNetworkObject:(AMBNetworkObject *)o url:(NSString *)u universalToken:(NSString *)uToken universalID:(NSString *)uID additionParams:(NSMutableDictionary*)additionalParams requestType:(NSString*)requestType completion:(void (^)(NSData *, NSURLResponse *, NSError *))c {
    NSError *e;
    NSData *b = o? [o toDataError:&e] : nil;
    if (e) {
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, nil, e); }); }
        return;
    }

    [[AMBAmbassadorNetworkManager sharedInstance] dataTaskForRequest:[[AMBAmbassadorNetworkManager sharedInstance] urlRequestFor:u body:b requestType:requestType authorization:uToken additionalParameters:additionalParams] session:[NSURLSession sharedSession] completion:c];
}

- (void)pusherChannelNameUniversalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *e))c {
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:[AMBAmbassadorNetworkManager pusherSessionSubscribeUrl] universalToken:uToken universalID:uID additionParams:nil requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) {
            dispatch_async(dispatch_get_main_queue(), ^{ c(nil, nil, e); });
        } else {
            NSMutableDictionary *payloadDict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&e];
            dispatch_async(dispatch_get_main_queue(), ^{ c(payloadDict[@"channel_name"], payloadDict, e); });
        }
    }];
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
    return [NSString stringWithFormat:@"%@auth/subscribe/", [self baseUrl]];
}

+ (NSString *)pusherSessionSubscribeUrl {
    return [NSString stringWithFormat:@"%@auth/session/", [self baseUrl]];
}

+ (NSString *)sendIdentifyUrl {
    return [NSString stringWithFormat:@"%@universal/action/identify/", [self baseUrl]];
}

+ (NSString *)sendShareTrackUrl {
    return [NSString stringWithFormat:@"%@track/share/", [self baseUrl]];
}

@end
