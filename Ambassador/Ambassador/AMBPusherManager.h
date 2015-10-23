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
- (void)subscribeTo:(NSString *)chan pusherChanDict:(NSMutableDictionary*)pushDict completion:(void(^)(AMBPTPusherChannel *, NSError *))completion;
- (void)resubscribeToExistingChannelWithCompletion:(void(^)(AMBPTPusherChannel *, NSError *))completion;
- (void)bindToChannelEvent:(NSString *)event handler:(void(^)(AMBPTPusherEvent *))handler;

@end

