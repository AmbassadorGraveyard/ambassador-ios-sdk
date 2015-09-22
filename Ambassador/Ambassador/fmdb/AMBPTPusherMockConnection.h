//
//  PTPusherMockConnection.h
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBPTPusherConnection.h"

#define kPTPusherSimulatedDisconnectionErrorCode 1001

@interface AMBPTPusherMockConnection : AMBPTPusherConnection

@property (nonatomic, readonly) NSArray *sentClientEvents;

- (void)simulateServerEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName;
- (void)simulateServerEventNamed:(NSString *)name data:(id)data;
- (void)simulateUnexpectedDisconnection;

@end
