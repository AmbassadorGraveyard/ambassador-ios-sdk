//
//  AMBPusherManager.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBPTPusher.h"

@interface AMBPusherManager : NSObject

@property (nonatomic) PTPusherConnectionState connectionState;

+ (instancetype)sharedInstanceWithAuthorization:(NSString *)auth;
- (void)subscribeToChannel:(NSString *)channel completion:(void(^)(AMBPTPusherChannel *pusherChannel, NSError *error))completion;
- (void)resubscribeToExistingChannelWithCompletion:(void(^)(AMBPTPusherChannel *, NSError *))completion;
- (void)bindToChannelEvent:(NSString*)eventName;

@end

