//
//  AmbassadorSDK_Internal.h
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Ambassador/Ambassador.h>
#import "AMBNetworkObject.h"
#import "AMBPusher.h"



@interface AmbassadorSDK ()
+ (void)sendIdentifyWithEmail:(NSString *)email campaign:(NSString *)campaign enroll:(BOOL)enroll universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c;
+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSError *))c;
+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c;
+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID;

+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c;


+ (void)setUpdatedUserInfoCompletion:(void(^)(AMBUserNetworkObject *, NSError *))c;

@end
