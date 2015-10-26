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
#import "AMBPusherManager.h"



@interface AmbassadorSDK ()
+ (void)sendIdentifyWithCampaign:(NSString *)campaign enroll:(BOOL)enroll completion:(void(^)(NSError *))c;
+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSMutableDictionary *, NSError *))c;
+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c;
+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID;
+ (AmbassadorSDK*)sharedInstance;
+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) AMBPusherChannelObject *pusherChannelObj;
@property (nonatomic, strong) AMBPusherManager *pusherManager;
@property (nonatomic, strong) AMBUserNetworkObject *user;
@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) NSString *universalID;
@end
