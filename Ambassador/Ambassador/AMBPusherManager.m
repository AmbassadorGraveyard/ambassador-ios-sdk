//
//  AMBPusherManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBPusherManager.h"
#import "AMBPTPusherChannel.h"
#import "AMBNetworkObject.h"
#import "AMBUtilities.h"
#import "AmbassadorSDK_Internal.h"

@interface AMBPusherManager () <AMBPTPusherDelegate>

@property (nonatomic, strong) AMBPTPusher *client;
@property (nonatomic, strong) AMBPTPusherPrivateChannel *channel;
@property (nonatomic, copy) void (^completion)(AMBPTPusherChannel *pusherChannel, NSError *error);
@property (nonatomic, strong) NSString *universalToken;

@end


@implementation AMBPusherManager

+ (instancetype)sharedInstanceWithAuthorization:(NSString *)auth {
    static AMBPusherManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBPusherManager alloc] initWithAuthorization:auth]; });
    return _sharedInsance;
}

+ (NSString *)pusherKey {
#if AMBPRODUCTION
    return @"79576dbee58121cac49a";
#else
    return @"8bd3fe1994164f9b83f6";
#endif
}



#pragma mark - Initialization

- (instancetype)initWithAuthorization:(NSString *)auth {
    if (self = [super init]) {
        self.universalToken = auth;
        self.client = [AMBPTPusher pusherWithKey:[AMBPusherManager pusherKey] delegate:self encrypted:YES];
        self.client.authorizationURL = [NSURL URLWithString:[AMBValues getPusherAuthUrl]];
        self.connectionState = PTPusherConnectionDisconnected;
        [self.client connect];
    }
    return self;
}

- (void)subscribeToChannel:(NSString *)channel completion:(void(^)(AMBPTPusherChannel *pusherChannel, NSError *error))completion {
    [AmbassadorSDK sharedInstance].pusherChannelObj = [AMBValues getPusherChannelObject];
    self.completion = completion;
    self.channel = [self.client subscribeToPrivateChannelNamed:channel];
}

- (void)resubscribeToExistingChannelWithCompletion:(void(^)(AMBPTPusherChannel *, NSError *))completion {
    NSString *channelName = [AmbassadorSDK sharedInstance].pusherChannelObj.channelName;
    self.completion = completion;
    
    if (channelName && ![channelName isEqualToString:@""]) {
        self.channel = [self.client subscribeToPrivateChannelNamed:[AmbassadorSDK sharedInstance].pusherChannelObj.channelName];
        self.completion(self.channel, nil);
    } else {
        self.completion(self.channel, [NSError errorWithDomain:@"Could not find existing channel name to subscribe!" code:1 userInfo:nil]);
    }
}

- (void)bindToChannelEvent:(NSString *)event handler:(void(^)(AMBPTPusherEvent *))handler {
    [self.channel bindToEventNamed:event handleWithBlock:handler];
}


# pragma mark - PTPusher Delegate

- (void)pusher:(AMBPTPusher *)pusher willAuthorizeChannel:(AMBPTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request {
    AMBPusherAuthNetworkObject *pusherAuthObj = [[AMBPusherAuthNetworkObject alloc] init];
    request = [self modifyPusherAuthRequest:request authorization:self.universalToken];

    NSDictionary *httpBody = [AMBUtilities dictionaryFromQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    pusherAuthObj.auth_type = @"private";
    pusherAuthObj.socket_id = httpBody[@"socket_id"];
    pusherAuthObj.channel = channel.name;
    NSError *e;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:[pusherAuthObj toDictionary] options:0 error:&e];
    if (e) {
        [self throwComletion:nil error:e];
    } else {
        request.HTTPBody = bodyData;
    }
}

- (NSMutableURLRequest *)modifyPusherAuthRequest:(NSMutableURLRequest *)request authorization:(NSString *)auth {
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (void)pusher:(AMBPTPusher *)pusher didFailToSubscribeToChannel:(AMBPTPusherChannel *)channel withError:(NSError *)error {
    [self throwComletion:channel error:error];
}

- (void)pusher:(AMBPTPusher *)pusher didSubscribeToChannel:(AMBPTPusherChannel *)channel {
    DLog(@"Subscribed to channel - %@", channel.name);
    [self throwComletion:channel error:nil];
}

- (void)throwComletion:(AMBPTPusherChannel *)channel error:(NSError *)error {
    if (self.completion) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.completion(channel, error);
        }];
    }
}

- (void)pusher:(AMBPTPusher *)pusher connectionDidConnect:(AMBPTPusherConnection *)connection {
    // FUNCTIONALITY: Lets pusherManager know when the pusher socket has been CONNECTED
    DLog(@"Pusher connection state changed to CONNECTED");
    self.connectionState = PTPusherConnectionConnected;
}

- (BOOL)pusher:(AMBPTPusher *)pusher connectionWillAutomaticallyReconnect:(AMBPTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    return YES;
}

- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection failedWithError:(NSError *)error {
    // FUNCTIONALITY: Lets pusherManager know when the pusher socket has been DISCONNECTED
    DLog(@"Pusher connection state changed to DISCONNECTED");
    self.connectionState = PTPusherConnectionDisconnected;
}

- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
    // FUNCTIONALITY: Lets pusherManager know when the pusher socket has been DISCONNECTED
    DLog(@"Pusher connection state changed to DISCONNECTED");
    self.connectionState = PTPusherConnectionDisconnected;
}

@end
