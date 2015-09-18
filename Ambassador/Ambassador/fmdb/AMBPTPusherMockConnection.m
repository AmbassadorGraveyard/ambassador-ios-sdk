//
//  PTPusherMockConnection.m
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherMockConnection.h"
#import "AMBPTJSON.h"
#import "AMBPTPusherEvent.h"
#import "AMBSRWebSocket.h"

@interface AMBPTPusherConnection () <SRWebSocketDelegate>
@end

@implementation AMBPTPusherMockConnection {
  NSMutableArray *sentClientEvents;
}

@synthesize sentClientEvents;

- (id)init
{
  if ((self = [super initWithURL:nil])) {
    sentClientEvents = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)connect
{
  [self webSocketDidOpen:nil];
  
  NSInteger socketID = (NSInteger)[NSDate timeIntervalSinceReferenceDate];

  [self simulateServerEventNamed:PTPusherConnectionEstablishedEvent 
                            data:@{@"socket_id": @(socketID)}];
}

- (void)disconnect
{
  [self webSocket:nil didCloseWithCode:0 reason:nil wasClean:YES];
}

- (void)send:(id)object
{
  [self handleClientEvent:object];
}

#pragma mark - Event simulation

- (void)simulateServerEventNamed:(NSString *)name data:(id)data
{
  [self simulateServerEventNamed:name data:data channel:nil];
}

- (void)simulateServerEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName
{
  NSMutableDictionary *event = [NSMutableDictionary dictionary];
  
  event[PTPusherEventKey] = name;
  
  if (data) {
    event[PTPusherDataKey] = data;
  }
  
  if (channelName) {
    event[PTPusherChannelKey] = channelName;
  }
  
  NSString *message = [[AMBPTJSON JSONParser] JSONStringFromObject:event];
  
  [self webSocket:nil didReceiveMessage:message];
}

- (void)simulateUnexpectedDisconnection
{
  [self webSocket:nil didCloseWithCode:kPTPusherSimulatedDisconnectionErrorCode reason:nil wasClean:NO];
}

#pragma mark - Client event handling

- (void)handleClientEvent:(NSDictionary *)eventData
{
  AMBPTPusherEvent *event = [AMBPTPusherEvent eventFromMessageDictionary:eventData];
  
  [sentClientEvents addObject:event];
  
  if ([event.name isEqualToString:@"pusher:subscribe"]) {
    [self handleSubscribeEvent:event];
  }
}

- (void)handleSubscribeEvent:(AMBPTPusherEvent *)subscribeEvent
{
  [self simulateServerEventNamed:@"pusher_internal:subscription_succeeded" 
                            data:nil
                         channel:(subscribeEvent.data)[PTPusherChannelKey]];
}

@end
