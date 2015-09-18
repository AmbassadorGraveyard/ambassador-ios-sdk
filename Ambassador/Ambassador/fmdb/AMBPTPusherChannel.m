//
//  PTPusherClient.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherChannel.h"
#import "AMBPTPusher.h"
#import "AMBPTPusherEvent.h"
#import "AMBPTPusherEventDispatcher.h"
#import "PTTargetActionEventListener.h"
#import "PTBlockEventListener.h"
#import "AMBPTPusherChannelAuthorizationOperation.h"
#import "PTPusherErrors.h"
#import "AMBPTJSON.h"

@interface AMBPTPusher ()
- (void)__unsubscribeFromChannel:(AMBPTPusherChannel *)channel;
- (void)beginAuthorizationOperation:(AMBPTPusherChannelAuthorizationOperation *)operation;
@end

@interface AMBPTPusherChannel ()
@property (nonatomic, weak) AMBPTPusher *pusher;
@property (nonatomic, strong) AMBPTPusherEventDispatcher *dispatcher;
@property (nonatomic, assign, readwrite) BOOL subscribed;
@property (nonatomic, readonly) NSMutableArray *internalBindings;
@end

#pragma mark -

@implementation AMBPTPusherChannel

+ (instancetype)channelWithName:(NSString *)name pusher:(AMBPTPusher *)pusher
{
  if ([name hasPrefix:@"private-"]) {
    return [[PTPusherPrivateChannel alloc] initWithName:name pusher:pusher];
  }
  if ([name hasPrefix:@"presence-"]) {
    return [[AMBPTPusherPresenceChannel alloc] initWithName:name pusher:pusher];
  }
  return [[self alloc] initWithName:name pusher:pusher];
}

- (id)initWithName:(NSString *)channelName pusher:(AMBPTPusher *)aPusher
{
  if (self = [super init]) {
    _name = [channelName copy];
    _pusher = aPusher;
    _dispatcher = [[AMBPTPusherEventDispatcher alloc] init];
    _internalBindings = [[NSMutableArray alloc] init];
    
    /*
     Set up event handlers for pre-defined channel events
     
     We *must* use block-based bindings with a weak reference to the channel.
     Using a target-action binding will create a retain cycle between the channel
     and the target/action binding object.
     */
    __weak AMBPTPusherChannel *weakChannel = self;
    
    [self.internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:subscription_succeeded" 
            handleWithBlock:^(AMBPTPusherEvent *event) {
              [weakChannel handleSubscribeEvent:event];
            }]];
    
    [self.internalBindings addObject:
     [self bindToEventNamed:@"subscription_error" 
            handleWithBlock:^(AMBPTPusherEvent *event) {
              [weakChannel handleSubcribeErrorEvent:event];
            }]];
  }
  return self;
}

- (void)dealloc 
{
  [self.internalBindings enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
    [_dispatcher removeBinding:object];
  }];
}

- (BOOL)isPrivate
{
  return NO;
}

- (BOOL)isPresence
{
  return NO;
}

#pragma mark - Subscription events

- (void)handleSubscribeEvent:(AMBPTPusherEvent *)event
{
  self.subscribed = YES;
  
  if ([self.pusher.delegate respondsToSelector:@selector(pusher:didSubscribeToChannel:)]) {
    [self.pusher.delegate pusher:self.pusher didSubscribeToChannel:self];
  }
}

- (void)handleSubcribeErrorEvent:(AMBPTPusherEvent *)event
{
  if ([self.pusher.delegate respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
    NSDictionary *userInfo = @{PTPusherErrorUnderlyingEventKey: event};
    NSError *error = [NSError errorWithDomain:AMBPTPusherErrorDomain code:PTPusherSubscriptionError userInfo:userInfo];
    [self.pusher.delegate pusher:self.pusher didFailToSubscribeToChannel:self withError:error];
  }
}

#pragma mark - Authorization

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  completionHandler(YES, @{}, nil); // public channels do not require authorization
}

#pragma mark - Binding to events

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  return [self.dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
}

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block
{
  return [self bindToEventNamed:eventName handleWithBlock:block queue:dispatch_get_main_queue()];
}

- (AMBPTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue
{
  return [self.dispatcher addEventListenerForEventNamed:eventName block:block queue:queue];
}

- (void)removeBinding:(AMBPTPusherEventBinding *)binding
{
  [self.dispatcher removeBinding:binding];
}

- (void)removeAllBindings
{
  NSMutableArray *bindingsToRemove = [NSMutableArray array];
  
  // need to unpack the bindings from the nested arrays, so we can
  // iterate over them safely whilst removing them from the dispatcher
  for (NSArray *bindingsArray in [self.dispatcher.bindings allValues]) {
    for (AMBPTPusherEventBinding *binding in bindingsArray) {
	    if (![self.internalBindings containsObject:binding]) {
        [bindingsToRemove addObject:binding];
      }
	  }
  }
  
  for (AMBPTPusherEventBinding *binding in bindingsToRemove) {
    [self.dispatcher removeBinding:binding];
  }
}

#pragma mark - Dispatching events

- (void)dispatchEvent:(AMBPTPusherEvent *)event
{
  [self.dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:AMBPTPusherEventReceivedNotification 
   object:self 
   userInfo:@{AMBPTPusherEventUserInfoKey: event}];
}

#pragma mark - Internal use only

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  [self.pusher sendEventNamed:@"pusher:subscribe"
                    data:@{@"channel": self.name}
                 channel:nil];
}

- (void)unsubscribe
{
  [self.pusher __unsubscribeFromChannel:self];
}

- (void)handleDisconnect
{
  self.subscribed = NO;
}

@end

#pragma mark -

@implementation PTPusherPrivateChannel {
  NSOperationQueue *_clientEventQueue;
}

- (id)initWithName:(NSString *)channelName pusher:(AMBPTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    _clientEventQueue = [[NSOperationQueue alloc] init];
    _clientEventQueue.maxConcurrentOperationCount = 1;
    _clientEventQueue.name = @"com.pusher.libPusher.clientEventQueue";
    _clientEventQueue.suspended = YES;
  }
  return self;
}

- (void)handleSubscribeEvent:(AMBPTPusherEvent *)event
{
  [super handleSubscribeEvent:event];
  [_clientEventQueue setSuspended:NO];
}

- (void)handleDisconnect
{
  [super handleDisconnect];
  [_clientEventQueue setSuspended:YES];
}

- (BOOL)isPrivate
{
  return YES;
}

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  AMBPTPusherChannelAuthorizationOperation *authOperation = [AMBPTPusherChannelAuthorizationOperation operationWithAuthorizationURL:self.pusher.authorizationURL channelName:self.name socketID:self.pusher.connection.socketID];
  
  [authOperation setCompletionHandler:^(AMBPTPusherChannelAuthorizationOperation *operation) {
    completionHandler(operation.isAuthorized, operation.authorizationData, operation.error);
  }];
    
  if ([self.pusher.delegate respondsToSelector:@selector(pusher:willAuthorizeChannel:withRequest:)]) {
    [self.pusher.delegate pusher:self.pusher willAuthorizeChannel:self withRequest:authOperation.mutableURLRequest];
  }
  
  [self.pusher beginAuthorizationOperation:authOperation];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  NSMutableDictionary *eventData = [authData mutableCopy];
  eventData[@"channel"] = self.name;
  
  [self.pusher sendEventNamed:@"pusher:subscribe"
                    data:eventData
                 channel:nil];
}

#pragma mark - Triggering events

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData
{
  if (![eventName hasPrefix:@"client-"]) {
    eventName = [@"client-" stringByAppendingString:eventName];
  }
  
  __weak AMBPTPusherChannel *weakSelf = self;
  
  [_clientEventQueue addOperationWithBlock:^{
    [weakSelf.pusher sendEventNamed:eventName data:eventData channel:weakSelf.name];
  }];
}

@end

#pragma mark -

@interface PTPusherChannelMembers ()

@property (nonatomic, copy, readwrite) NSString *myID;

- (void)reset;
- (void)handleSubscription:(NSDictionary *)subscriptionData;
- (AMBPTPusherChannelMember *)handleMemberAdded:(NSDictionary *)memberData;
- (AMBPTPusherChannelMember *)handleMemberRemoved:(NSDictionary *)memberData;

@end

@implementation AMBPTPusherPresenceChannel

- (id)initWithName:(NSString *)channelName pusher:(AMBPTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    _members = [[PTPusherChannelMembers alloc] init];

    /* Set up event handlers for pre-defined channel events.
     As above, use blocks as proxies to a weak channel reference to avoid retain cycles.
     */
      __weak AMBPTPusherPresenceChannel *weakChannel = self;
    
    [self.internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:member_added" 
            handleWithBlock:^(AMBPTPusherEvent *event) {
              [weakChannel handleMemberAddedEvent:event];
            }]];
    
    [self.internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:member_removed" 
            handleWithBlock:^(AMBPTPusherEvent *event) {
              [weakChannel handleMemberRemovedEvent:event];
            }]];
    
  }
  return self;
}

- (void)handleDisconnect
{
  [super handleDisconnect];
  [self.members reset];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  [super subscribeWithAuthorization:authData];
  
  NSDictionary *channelData = [[AMBPTJSON JSONParser] objectFromJSONString:authData[@"channel_data"]];
  self.members.myID = channelData[@"user_id"];
}

- (void)handleSubscribeEvent:(AMBPTPusherEvent *)event
{
  [super handleSubscribeEvent:event];
  [self.members handleSubscription:event.data];
  [self.presenceDelegate presenceChannelDidSubscribe:self];
}

- (BOOL)isPresence
{
  return YES;
}

- (void)handleMemberAddedEvent:(AMBPTPusherEvent *)event
{
  AMBPTPusherChannelMember *member = [self.members handleMemberAdded:event.data];

  [self.presenceDelegate presenceChannel:self memberAdded:member];
}

- (void)handleMemberRemovedEvent:(AMBPTPusherEvent *)event
{
  AMBPTPusherChannelMember *member = [self.members handleMemberRemoved:event.data];
  
  [self.presenceDelegate presenceChannel:self memberRemoved:member];
}

@end

#pragma mark -

@implementation AMBPTPusherChannelMember

- (id)initWithUserID:(NSString *)userID userInfo:(NSDictionary *)userInfo
{
  if ((self = [super init])) {
    _userID = [userID copy];
    _userInfo = [userInfo copy];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherChannelMember id:%@ info:%@>", self.userID, self.userInfo];
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
  return self.userInfo[key];
}

@end

@implementation PTPusherChannelMembers {
  NSMutableDictionary *_members;
}

- (id)init
{
  self = [super init];
  if (self) {
    _members = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)reset
{
  _members = [[NSMutableDictionary alloc] init];
  self.myID = nil;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherChannelMembers members:%@>", _members];
}

- (NSInteger)count
{
  return _members.count;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
  return _members[key];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
  [_members enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    block(obj, stop);
  }];
}


- (AMBPTPusherChannelMember *)me
{
  return self[self.myID];
}

- (AMBPTPusherChannelMember *)memberWithID:(NSString *)userID
{
  return self[userID];
}

#pragma mark - Channel event handling

- (void)handleSubscription:(NSDictionary *)subscriptionData
{
  NSDictionary *memberHash = subscriptionData[@"presence"][@"hash"];
  
  [memberHash enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSDictionary *userInfo, BOOL *stop) {
    AMBPTPusherChannelMember *member = [[AMBPTPusherChannelMember alloc] initWithUserID:userID userInfo:userInfo];
    _members[userID] = member;
  }];
}

- (AMBPTPusherChannelMember *)handleMemberAdded:(NSDictionary *)memberData
{
  AMBPTPusherChannelMember *member = [self memberWithID:memberData[@"user_id"]];
  if (member == nil) {
    member = [[AMBPTPusherChannelMember alloc] initWithUserID:memberData[@"user_id"] userInfo:memberData[@"user_info"]];
    _members[member.userID] = member;
  }
  return member;
}

- (AMBPTPusherChannelMember *)handleMemberRemoved:(NSDictionary *)memberData
{
  AMBPTPusherChannelMember *member = [self memberWithID:memberData[@"user_id"]];
  if (member) {
    [_members removeObjectForKey:member.userID];
  }
  return member;
}

@end
