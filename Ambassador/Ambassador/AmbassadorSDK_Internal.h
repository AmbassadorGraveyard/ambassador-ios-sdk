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

@protocol AmbassadorDelegate <NSObject>

@optional
- (void)userInfoUpdated:(AMBUserNetworkObject *)user;
- (void)recievedConversionError:(NSError *)error;
- (void)recievedRafError:(NSError *)error;
@end

@interface AmbassadorSDK ()
+ (void)sendIdentifyWithEmail:(NSString *)email campaign:(NSString *)campaign enroll:(BOOL)enroll universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c;
+ (void)pusherChannelUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSString *, NSError *))c;
+ (void)startPusherUniversalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(AMBPTPusherChannel* chan, NSError* e))c;
+ (void)bindToIdentifyActionUniversalToken:(NSString *)uTok universalID:(NSString *)uID;

+ (void)identifyWithEmail:(NSString *)email completion:(void(^)(NSError *))c;

@property id<AmbassadorDelegate>delegate;
@end
