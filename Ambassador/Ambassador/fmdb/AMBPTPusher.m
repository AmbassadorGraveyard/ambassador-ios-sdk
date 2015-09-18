//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusher.h"
#import "AMBPTEventListener.h"
#import "AMBPTPusherEvent.h"
#import "AMBPTPusherChannel.h"
#import "AMBPTPusherEventDispatcher.h"
#import "AMBPTTargetActionEventListener.h"
#import "AMBPTBlockEventListener.h"
#import "AMBPTPusherErrors.h"
#import "AMBPTPusherChannelAuthorizationOperation.h"
#import "AMBPTPusherChannel_Private.h"

#define kPUSHER_HOST @"ws.pusherapp.com"

typedef NS_ENUM(NSUInteger, AMBPTPusherAutoReconnectMode) {
  AMBPTPusherAutoReconnectModeNoReconnect,
  AMBPTPusherAutoReconnectModeReconnectImmediately,
  AMBPTPusherAutoReconnectModeReconnectWithConfiguredDelay,
  AMBPTPusherAutoReconnectModeReconnectWithBackoffDelay
};

NSURL *AMBPTPusherConnectionURL(NSString *host, NSString *key, NSString *clientID, BOOL secure);

NSString *const AMBPTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";
NSString *const AMBPTPusherEventUserInfoKey          = @"PTPusherEventUserInfoKey";
NSString *const AMBPTPusherErrorDomain               = @"PTPusherErrorDomain";
NSString *const AMBPTPusherFatalErrorDomain          = @"PTPusherFatalErrorDomain";
NSString *const AMBPTPusherErrorUnderlyingEventKey   = @"PTPusherErrorUnderlyingEventKey";

/** The Pusher protocol version, used to determined which features
 are supported.
 */
#define AMBkPTPusherClientProtocolVersion 6

NSURL *AMBPTPusherConnectionURL(NSString *host, NSString *key, NSString *clientID, BOOL encrypted)
{
  NSString *scheme = ((encrypted == YES) ? @"wss" : @"ws");
  NSString *URLString = [NSString stringWithFormat:@"%@://%@/app/%@?client=%@&protocol=%d&version=%@", 
                         scheme, host, key, clientID, AMBkPTPusherClientProtocolVersion, @"1.6"];
  return [NSURL URLWithString:URLString];
}

#define AMBkPTPusherDefaultReconnectDelay 5.0

@interface AMBPTPusher ()
@property (nonatomic, strong, readwrite) AMBPTPusherConnection *connection;
@property (nonatomic, assign) AMBPTPusherAutoReconnectMode autoReconnectMode;
@end

#pragma mark -

@implementation AMBPTPusher {
  NSOperationQueue *authorizationQueue;
  NSUInteger _numberOfReconnectAttempts;
  NSUInteger _maximumNumberOfReconnectAttempts;
  AMBPTPusherEventDispatcher *dispatcher;
  NSMutableDictionary *channels;
}

- (id)initWithConnection:(AMBPTPusherConnection *)connection
{
  if (self = [super init]) {
    dispatcher = [[AMBPTPusherEventDispatcher alloc] init];
    channels = [[NSMutableDictionary alloc] init];
    
    authorizationQueue = [[NSOperationQueue alloc] init];
    authorizationQueue.maxConcurrentOperationCount = 5;
    authorizationQueue.name = @"com.pusher.libPusher.authorizationQueue";
    
    self.connection = connection;
    self.connection.delegate = self;
    self.reconnectDelay = AMBkPTPusherDefaultReconnectDelay;
    
    /* Three reconnection attempts should be more than enough attempts
     * to reconnect where the user has simply locked their device or
     * backgrounded the app.
     *
     * If there is no internet connection, we will only end up retrying
     * once as after the first failure we will no longer auto-retry.
     *
     * We may consider making this user-customisable in future but not 
     * for now.
     */
    _maximumNumberOfReconnectAttempts = 3;
  }
  return self;
}

+ (instancetype)pusherWithKey:(NSString *)key delegate:(id<AMBPTPusherDelegate>)delegate
{
  return [self pusherWithKey:key delegate:delegate encrypted:YES];
}

+ (instancetype)pusherWithKey:(NSString *)key delegate:(id<AMBPTPusherDelegate>)delegate encrypted:(BOOL)isEncrypted
{
  return [self pusherWithKey:(NSString *)key delegate:(id<AMBPTPusherDelegate>)delegate encrypted:(BOOL)isEncrypted cluster:(NSString *) nil];
}

+ (instancetype)pusherWithKey:(NSString *)key delegate:(id<AMBPTPusherDelegate>)delegate encrypted:(BOOL)isEncrypted cluster:(NSString *) cluster
{
    NSString * hostURL;
    if ([cluster length] == 0) {
        hostURL = kPUSHER_HOST;
    } else {
        hostURL = [NSString stringWithFormat:@"ws-%@.pusher.com", cluster];
    }

    NSURL *serviceURL = AMBPTPusherConnectionURL(hostURL, key, @"libPusher", isEncrypted);
    AMBPTPusherConnection *connection = [[AMBPTPusherConnection alloc] initWithURL:serviceURL];
    AMBPTPusher *pusher = [[self alloc] initWithConnection:connection];
    pusher.delegate = delegate;
    return pusher;
}

- (void)dealloc;
{
  [_connection setDelegate:nil];
  [_connection disconnect];
}

#pragma mark - Connection management

- (void)setReconnectDelay:(NSTimeInterval)reconnectDelay
{
  _reconnectDelay = MAX(reconnectDelay, 1);
}

- (void)connect
{
  _numberOfReconnectAttempts = 0;
  self.autoReconnectMode = AMBPTPusherAutoReconnectModeReconnectWithConfiguredDelay;
  [self.connection connect];
}

- (void)disconnect
{
  // we do not want to reconnect if a user explicitly disconnects
  self.autoReconnectMode = AMBPTPusherAutoReconnectModeNoReconnect;
  [self.connection disconnect];
}

#pragma mark - Binding to events

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  return [dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
}

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block
{
  return [self bindToEventNamed:eventName handleWithBlock:block queue:dispatch_get_main_queue()];
}

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue
{
  return [dispatcher addEventListenerForEventNamed:eventName block:block queue:queue];
}

- (void)removeBinding:(AMBPTPusherEventBinding *)binding
{
  [dispatcher removeBinding:binding];
}

- (void)removeAllBindings
{
  [dispatcher removeAllBindings];
}

#pragma mark - Subscribing to channels

- (AMBPTPusherChannel *)subscribeToChannelNamed:(NSString *)name
{
  AMBPTPusherChannel *channel = channels[name];
  if (channel == nil) {
    channel = [AMBPTPusherChannel channelWithName:name pusher:self]; 
    channels[name] = channel;
  }
  // private/presence channels require a socketID to authenticate
  if (self.connection.isConnected && self.connection.socketID) {
    [self subscribeToChannel:channel];
  }
  return channel;
}

- (AMBPTPusherPrivateChannel *)subscribeToPrivateChannelNamed:(NSString *)name
{
  return (AMBPTPusherPrivateChannel *)[self subscribeToChannelNamed:[NSString stringWithFormat:@"private-%@", name]];
}

- (AMBPTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name
{
  return (AMBPTPusherPresenceChannel *)[self subscribeToChannelNamed:[NSString stringWithFormat:@"presence-%@", name]];
}

- (AMBPTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name delegate:(id<AMBPTPusherPresenceChannelDelegate>)presenceDelegate
{
  AMBPTPusherPresenceChannel *channel = [self subscribeToPresenceChannelNamed:name];
  channel.presenceDelegate = presenceDelegate;
  return channel;
}

- (AMBPTPusherChannel *)channelNamed:(NSString *)name
{
  return channels[name];
}

/* This is only called when a client explicitly unsubscribes from a channel
 * by calling either [channel unsubscribe] or using the deprecated API 
 * [client unsubscribeFromChannel:].
 *
 * This effectively ends the lifetime of a channel: the client will remove it
 * from it's channels collection and all bindings will be removed. If no other
 * code outside of libPusher has a strong reference to the channel, it will
 * be deallocated.
 *
 * This is different to implicit unsubscribes (where the connection has been lost)
 * where the channel will object will remain and be re-subscribed when connection
 * is re-established.
 *
 * A pusher:unsubscribe event will only be sent if there is a connection, otherwise
 * it's not necessary as the channel is already implicitly unsubscribed due to the
 * disconnection.
 */
- (void)__unsubscribeFromChannel:(AMBPTPusherChannel *)channel
{
  NSParameterAssert(channel != nil);
  
  [channel removeAllBindings];
  
  if (self.connection.isConnected) {
    [self sendEventNamed:@"pusher:unsubscribe"
                    data:@{@"channel": channel.name}];
  }
  
  [channels removeObjectForKey:channel.name];
  
  if ([self.delegate respondsToSelector:@selector(pusher:didUnsubscribeFromChannel:)]) {
    [self.delegate pusher:self didUnsubscribeFromChannel:channel];
  }
}

- (void)subscribeToChannel:(AMBPTPusherChannel *)channel
{
  [channel authorizeWithCompletionHandler:^(BOOL isAuthorized, NSDictionary *authData, NSError *error) {
    if (isAuthorized && self.connection.isConnected) {
      if ([self.delegate respondsToSelector:@selector(pusher:authorizationPayloadFromResponseData:)]) {
        authData = [self.delegate pusher:self authorizationPayloadFromResponseData:authData];
      }    
      [channel subscribeWithAuthorization:authData];
    }
    else {
      if (error == nil) {
        error = [NSError errorWithDomain:AMBPTPusherErrorDomain code:AMBPTPusherSubscriptionUnknownAuthorisationError userInfo:nil];
      }
      
      if ([self.delegate respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
        [self.delegate pusher:self didFailToSubscribeToChannel:channel withError:error];
      }
    }
  }];
}

- (void)subscribeAll
{
  for (AMBPTPusherChannel *channel in [channels allValues]) {
    [self subscribeToChannel:channel];
  }
}

#pragma mark - Sending events

- (void)sendEventNamed:(NSString *)name data:(id)data
{
  [self sendEventNamed:name data:data channel:nil];
}

- (void)sendEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName
{
  NSParameterAssert(name);
  
  if (self.connection.isConnected == NO) {
    NSLog(@"Warning: attempting to send event while disconnected. Event will not be sent.");
    return;
  }
  
  NSMutableDictionary *payload = [NSMutableDictionary dictionary];  
  payload[AMBPTPusherEventKey] = name;
  
  if (data) {
    payload[AMBPTPusherDataKey] = data;
  }
  
  if (channelName) {
    payload[AMBPTPusherChannelKey] = channelName;
  }
  [self.connection send:payload];
}

#pragma mark - PTPusherConnection delegate methods

- (BOOL)pusherConnectionWillConnect:(AMBPTPusherConnection *)connection
{
  if ([self.delegate respondsToSelector:@selector(pusher:connectionWillConnect:)]) {
    return [self.delegate pusher:self connectionWillConnect:connection];
  }
  return YES;
}

- (void)pusherConnectionDidConnect:(AMBPTPusherConnection *)connection
{
  _numberOfReconnectAttempts = 0;
  
  if ([self.delegate respondsToSelector:@selector(pusher:connectionDidConnect:)]) {
    [self.delegate pusher:self connectionDidConnect:connection];
  }
  
  [self subscribeAll];
}

- (void)pusherConnection:(AMBPTPusherConnection *)connection didDisconnectWithCode:(NSInteger)errorCode reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  NSError *error = nil;
  
  if (errorCode > 0) {
    if (reason == nil) {
        reason = @"Unknown error"; // not sure what could cause this to be nil, but just playing it safe
    }
    
    NSString *errorDomain = AMBPTPusherErrorDomain;

    if (errorCode >= 400 && errorCode <= 4099) {
      errorDomain = AMBPTPusherFatalErrorDomain;
    }
    
    // check for error codes based on the Pusher Websocket protocol see http://pusher.com/docs/pusher_protocol
    error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{@"reason": reason}];
    
    // 4000-4099 -> The connection SHOULD NOT be re-established unchanged.
    if (errorCode >= 4000 && errorCode <= 4099) {
      [self handleDisconnection:connection error:error reconnectMode:AMBPTPusherAutoReconnectModeNoReconnect];
    } else
    // 4200-4299 -> The connection SHOULD be re-established immediately.
    if(errorCode >= 4200 && errorCode <= 4299) {
      [self handleDisconnection:connection error:error reconnectMode:AMBPTPusherAutoReconnectModeReconnectImmediately];
    }
    
    else {
      // i.e. 4100-4199 -> The connection SHOULD be re-established after backing off.
      [self handleDisconnection:connection error:error reconnectMode:AMBPTPusherAutoReconnectModeReconnectWithBackoffDelay];
    }
  }
  else {
    [self handleDisconnection:connection error:error reconnectMode:self.autoReconnectMode];
  }
}

- (void)pusherConnection:(AMBPTPusherConnection *)connection didFailWithError:(NSError *)error wasConnected:(BOOL)wasConnected
{
  if (wasConnected) {
    [self handleDisconnection:connection error:error reconnectMode:AMBPTPusherAutoReconnectModeReconnectImmediately];
  }
  else {
    if ([self.delegate respondsToSelector:@selector(pusher:connection:failedWithError:)]) {
      [self.delegate pusher:self connection:connection failedWithError:error];
    }
  }
}

- (void)pusherConnection:(AMBPTPusherConnection *)connection didReceiveEvent:(AMBPTPusherEvent *)event
{
  if ([event isKindOfClass:[AMBPTPusherErrorEvent class]]) {
    if ([self.delegate respondsToSelector:@selector(pusher:didReceiveErrorEvent:)]) {
      [self.delegate pusher:self didReceiveErrorEvent:(AMBPTPusherErrorEvent *)event];
    }
  }
  
  if (event.channel) {
    [channels[event.channel] dispatchEvent:event];
  }
  [dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
     postNotificationName:AMBPTPusherEventReceivedNotification
     object:self 
     userInfo:@{AMBPTPusherEventUserInfoKey: event}];
}

- (void)handleDisconnection:(AMBPTPusherConnection *)connection error:(NSError *)error reconnectMode:(AMBPTPusherAutoReconnectMode)reconnectMode
{
  [authorizationQueue cancelAllOperations];
  
  for (AMBPTPusherChannel *channel in [channels allValues]) {
    [channel handleDisconnect];
  }
  
  BOOL willReconnect = NO;
  
  if (reconnectMode > AMBPTPusherAutoReconnectModeNoReconnect && _numberOfReconnectAttempts < _maximumNumberOfReconnectAttempts) {
    willReconnect = YES;
  }
    
  if ([self.delegate respondsToSelector:@selector(pusher:connection:didDisconnectWithError:willAttemptReconnect:)]) {
    [self.delegate pusher:self connection:connection didDisconnectWithError:error willAttemptReconnect:willReconnect];
  }
  
  if (willReconnect) {
    [self reconnectUsingMode:reconnectMode];
  }
}

#pragma mark - Private

- (void)beginAuthorizationOperation:(AMBPTPusherChannelAuthorizationOperation *)operation
{
  [authorizationQueue addOperation:operation];
}

- (void)reconnectUsingMode:(AMBPTPusherAutoReconnectMode)reconnectMode
{
  _numberOfReconnectAttempts++;
  
  NSTimeInterval delay;
  
  switch (reconnectMode) {
    case AMBPTPusherAutoReconnectModeReconnectImmediately:
      delay = 0;
      break;
    case AMBPTPusherAutoReconnectModeReconnectWithConfiguredDelay:
      delay = self.reconnectDelay;
      break;
    case AMBPTPusherAutoReconnectModeReconnectWithBackoffDelay:
      delay = self.reconnectDelay * _numberOfReconnectAttempts;
      break;
    default:
      delay = 0;
      break;
  }
  
  if ([self.delegate respondsToSelector:@selector(pusher:connectionWillAutomaticallyReconnect:afterDelay:)]) {
    BOOL shouldProceed = [self.delegate pusher:self connectionWillAutomaticallyReconnect:_connection afterDelay:delay];
    
    if (!shouldProceed) return;
  }
  
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [_connection connect];
  });
}

@end
