//
//  PTPusherPresenceChannelDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherMacros.h"

@class AMBPTPusherChannelMember;
@class AMBPTPusherPresenceChannel;

@protocol AMBPTPusherPresenceChannelDelegate <NSObject>

/** Notifies the delegate that the presence channel subscribed successfully.
 
 Whenever you subscribe to a presence channel, a list of current subscribers will be returned by Pusher.
 
 The members list can be accessed using the `members` property on the channel.

 @param channel The presence channel that was subscribed to.
 */
- (void)presenceChannelDidSubscribe:(AMBPTPusherPresenceChannel *)channel;

/** Notifies the delegate that a member has joined the channel.
 
 @param channel The presence channel that was subscribed to.
 @param member The member that was removed.
 */

- (void)presenceChannel:(AMBPTPusherPresenceChannel *)channel memberAdded:(AMBPTPusherChannelMember *)member;

/** Notifies the delegate that a member has left from the channel.

 @param channel The presence channel that was subscribed to.
 @param member The member that was removed.
 */
- (void)presenceChannel:(AMBPTPusherPresenceChannel *)channel memberRemoved:(AMBPTPusherChannelMember *)member;

@end
