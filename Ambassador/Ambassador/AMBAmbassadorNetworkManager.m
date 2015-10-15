//
//  AMBAmbassadorNetworkManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBAmbassadorNetworkManager.h"
#import "AMBErrors.h"

@implementation AMBAmbassadorNetworkManager
+ (instancetype)sharedInstance {
    static AMBAmbassadorNetworkManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBAmbassadorNetworkManager alloc] init]; });
    return _sharedInsance;
}

- (void)sendNetworkObject:(AMBNetworkObject *)o url:(NSString *)u universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSData *, NSURLResponse *, NSError *))c {
    NSError *e;
    NSData *b = o? [o toDataError:&e] : nil;
    if (e) {
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil, nil, e); }); }
        return;
    }
    [[AMBAmbassadorNetworkManager sharedInstance] dataTaskForRequest:[[AMBAmbassadorNetworkManager sharedInstance] urlRequestFor:u body:b authorization:uToken] session:[NSURLSession sharedSession] completion:c];
}

+ (NSString *)baseUrl {
//#if AMBPRODUCTION
//    return @"https://dev-ambassador-api.herokuapp.com/";
//# else
//    return @"https://api.getambassador.com/universal/";
//#endif
    
    if (YES) {
         return @"https://dev-ambassador-api.herokuapp.com/";
    }
    return @"https://api.getambassador.com/universal/";
}

+ (NSString *)pusherAuthSubscribeUrl {
    return [NSString stringWithFormat:@"%@auth/subscribe/", [self baseUrl]];
}

+ (NSString *)pusherSessionSubscribeUrl {
    return [NSString stringWithFormat:@"%@session/subscribe/", [self baseUrl]];
}

@end
