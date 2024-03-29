//
//  PTPusherConnection.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherConnection.h"
#import "AMBPTPusherEvent.h"
#define SR_ENABLE_LOG
#import "AMBSRWebSocket.h"
#import "AMBPTJSON.h"

NSString *const AMBPTPusherConnectionEstablishedEvent = @"pusher:connection_established";
NSString *const AMBPTPusherConnectionPingEvent        = @"pusher:ping";
NSString *const AMBPTPusherConnectionPongEvent        = @"pusher:pong";

@interface AMBPTPusherConnection () <SRWebSocketDelegate>
@property (nonatomic, copy) NSString *socketID;
@property (nonatomic, assign) PTPusherConnectionState state;
@property (nonatomic, strong) NSTimer *pingTimer;
@property (nonatomic, strong) NSTimer *pongTimer;
@end

@implementation AMBPTPusherConnection {
  AMBSRWebSocket *socket;
  NSURLRequest *request;
}

- (id)initWithURL:(NSURL *)aURL
{
  if ((self = [super init])) {
    request = [NSURLRequest requestWithURL:aURL];
    
#ifdef DEBUG
    NSLog(@"[pusher] Debug logging enabled");
#endif
    
    // Timeout defaults as recommended by the Pusher protocol documentation.
    self.activityTimeout = 120.0;
    self.pongTimeout = 30.0;
  }
  return self;
}

- (void)dealloc
{
  [self.pingTimer invalidate];
  [self.pongTimer invalidate];
  [socket setDelegate:nil];
  [socket close];
}

- (BOOL)isConnected
{
  return (self.state == PTPusherConnectionConnected);
}

- (NSURL *)URL
{
  return request.URL;
}

#pragma mark - Connection management

- (void)connect;
{
  if (self.state >= PTPusherConnectionConnecting) return;
  
  BOOL shouldConnect = [self.delegate pusherConnectionWillConnect:self];
  
  if (!shouldConnect) return;
  
  socket = [[AMBSRWebSocket alloc] initWithURLRequest:request];
  socket.delegate = self;
  
  [socket open];
  
  self.state = PTPusherConnectionConnecting;
}

- (void)disconnect;
{
  if (self.state <= PTPusherConnectionDisconnected) return;
  
  [socket close];
  
  self.state = PTPusherConnectionDisconnecting;
}

#pragma mark - Sending data

- (void)send:(id)object
{
  if (self.isConnected == NO) return;
  
  NSData *JSONData = [[AMBPTJSON JSONParser] JSONDataFromObject:object];
  NSString *message = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
  [socket send:message];
}

#pragma mark - SRWebSocket delegate methods

- (void)webSocketDidOpen:(AMBSRWebSocket *)webSocket
{
  self.state = PTPusherConnectionAwaitingHandshake;
}

- (void)webSocket:(AMBSRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
  [self.pingTimer invalidate];
  [self.pongTimer invalidate];
  
  BOOL wasConnected = self.isConnected;
  self.state = PTPusherConnectionDisconnected;
  self.socketID = nil;
  socket = nil;
  
  // we always call this last, to prevent a race condition if the delegate calls 'connect'
  [self.delegate pusherConnection:self didFailWithError:error wasConnected:wasConnected];
}

- (void)webSocket:(AMBSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  [self.pingTimer invalidate];
  [self.pongTimer invalidate];
  
  self.state = PTPusherConnectionDisconnected;
  self.socketID = nil;
  socket = nil;
  
  // we always call this last, to prevent a race condition if the delegate calls 'connect'
  [self.delegate pusherConnection:self didDisconnectWithCode:(NSInteger)code reason:(NSString *)reason wasClean:wasClean];
}

- (void)webSocket:(AMBSRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
  [self resetPingPongTimer];
  
  NSDictionary *messageDictionary = [[AMBPTJSON JSONParser] objectFromJSONString:message];
  AMBPTPusherEvent *event = [AMBPTPusherEvent eventFromMessageDictionary:messageDictionary];
  
  if ([event.name isEqualToString:AMBPTPusherConnectionPongEvent]) {
#ifdef DEBUG
    NSLog(@"[pusher] Server responded to ping (pong!)");
#endif
    return;
  }
  
  if ([event.name isEqualToString:AMBPTPusherConnectionEstablishedEvent]) {
    self.socketID = (event.data)[@"socket_id"];
    self.state = PTPusherConnectionConnected;
    
    [self.delegate pusherConnectionDidConnect:self];
  }
  
  [self.delegate pusherConnection:self didReceiveEvent:event];
}

#pragma mark - Ping/Pong/Activity Timeouts

- (void)sendPing
{
  [self send:@{@"event": @"pusher:ping"}];
}

- (void)resetPingPongTimer
{
  [self.pingTimer invalidate];
  // Any activity also invalidates the pong timer if set
  [self.pongTimer invalidate];
  
  self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:self.activityTimeout target:self selector:@selector(handleActivityTimeout) userInfo:nil repeats:NO];
}

- (void)handleActivityTimeout
{
#ifdef DEBUG
  NSLog(@"[pusher] Pusher connection activity timeout reached, sending ping to server");
#endif
  
  [self sendPing];
  
  self.pongTimer = [NSTimer scheduledTimerWithTimeInterval:self.pongTimeout target:self selector:@selector(handlePongTimeout) userInfo:nil repeats:NO];
}

- (void)handlePongTimeout
{
#ifdef DEBUG
  NSLog(@"[pusher] Server did not respond to ping within timeout, disconnecting");
#endif
  
  [self disconnect];
}

@end
