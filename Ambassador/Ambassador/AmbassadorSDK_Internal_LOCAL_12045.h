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
#import "AMBPusherChannelObject.h"



@interface AmbassadorSDK ()
+ (void)sendIdentifyWithCampaign:(NSString *)campaign enroll:(BOOL)enroll completion:(void(^)(NSError *))c;
+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *))c;
+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c;
+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID;
+ (AmbassadorSDK*)sharedInstance;
+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c;
@property AMBUserNetworkObject *user;
@property NSString *universalToken;
@property NSString *universalID;
@property NSString *email;
@property AMBPusherChannelObject *pusherChannelObj;

@end
