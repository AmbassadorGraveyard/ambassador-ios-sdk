//
//  AMBAmbassadorNetworkManager.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBNetworkObject.h"
#import "AMBNetworkManager.h"

@interface AMBAmbassadorNetworkManager : AMBNetworkManager <NSURLConnectionDelegate>

+ (instancetype)sharedInstance;

- (void)sendNetworkObject:(AMBNetworkObject *)o url:(NSString *)u additionParams:(NSMutableDictionary*)additionalParams requestType:(NSString*)requestType completion:(void (^)(NSData *, NSURLResponse *, NSError *))c;
- (void)pusherChannelNameUniversalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *e))c;
+ (NSString *)pusherSessionSubscribeUrl;
+ (NSString *)pusherAuthSubscribeUrl;
+ (NSString *)sendIdentifyUrl;
+ (NSString *)sendShareTrackUrl;
+ (NSString *)bulkShareEmailUrl;
+ (NSString *)bulkShareSMSUrl;
@end
