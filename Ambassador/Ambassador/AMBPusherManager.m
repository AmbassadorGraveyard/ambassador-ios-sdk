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

@interface AMBPusherManager () <AMBPTPusherDelegate>
@property (nonatomic, strong) AMBPTPusher *client;
@property (nonatomic, strong) AMBPTPusherPrivateChannel *channel;
@property (nonatomic, copy) void (^completion)(AMBPTPusherChannel *c, NSError *e);
@property (nonatomic, strong) NSString *universalToken;
@property BOOL isAuthorized;
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
        self.client.authorizationURL = [NSURL URLWithString:[self pusherAuthUrl]];
        self.isAuthorized = NO;
        [self.client connect];
    }
    return self;
}

- (void)subscribeTo:(NSString *)chan completion:(void(^)(AMBPTPusherChannel *, NSError *))completion {
    self.completion = completion;
    self.channel = [self.client subscribeToPrivateChannelNamed:chan];
    if (self.isAuthorized) {
        self.completion(self.channel, nil);
        return;
    }
}

- (void)bindToChannelEvent:(NSString *)event handler:(void(^)(AMBPTPusherEvent *))handler {
    [self.channel bindToEventNamed:event handleWithBlock:handler];
    //[self.channel bindToEventNamed:event handleWithBlock:handler queue:dispatch_get_main_queue()];
}


#pragma mark - Url returns
- (NSString *)pusherAuthUrl {
    if (YES)
        return  @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";
    else
        return  @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/"; //TODO: change to production
}



# pragma mark - PTPusher Delegate
- (void)pusher:(AMBPTPusher *)pusher willAuthorizeChannel:(AMBPTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request {
    AMBPusherAuthNetworkObject *pusherAuthObj = [[AMBPusherAuthNetworkObject alloc] init];
    request = [self modifyPusherAuthRequest:request authorization:self.universalToken];
    NSMutableDictionary *httpBody = AMBparseQueryString([[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding]);
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
    self.isAuthorized = YES;
    DLog(@"Subscribed to chnnel %@", channel.name);
    [self throwComletion:channel error:nil];
}

- (void)throwComletion:(AMBPTPusherChannel *)c error:(NSError *)e {
    if (self.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak AMBPusherManager *weakSelf = self;
            weakSelf.completion(c, e);
        });
    }
}

@end
