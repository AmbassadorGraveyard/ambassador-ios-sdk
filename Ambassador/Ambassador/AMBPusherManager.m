//
//  AMBPusherManager.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBPusherManager.h"
#import "AMBPTPusherChannel.h"
#import "AMBPusherAuthNetworkObject.h"
#import "AMBUtilities.h"

@interface AMBPusherManager () <AMBPTPusherDelegate>
@property (nonatomic, strong) AMBPTPusher *client;
@property (nonatomic, strong) AMBPTPusherPrivateChannel *channel;
@property (nonatomic, copy) void (^completion)(AMBPTPusherChannel *c, NSError *e);
@property (nonatomic, strong) NSString *universalToken;
@end

@implementation AMBPusherManager
NSString * const PUSHER_KEY = @"8bd3fe1994164f9b83f6";
NSString * const CHANNEL_PREFIX = @"snippet-channel@user=";


#pragma mark - Initialization
- (instancetype)initWith:(NSString *)uToken universalID:(NSString *)uID {
    if (self = [super init]) {
        self.universalToken = uToken;
        self.client = [AMBPTPusher pusherWithKey:PUSHER_KEY delegate:self encrypted:YES];
        self.client.authorizationURL = [NSURL URLWithString:[self pusherAuthUrl]];
        [self.client connect];
    }
    return self;
}

- (void)subscribe:(NSString *)did completion:(void(^)(AMBPTPusherChannel *, NSError *))completion {
    self.completion = completion;
    self.channel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%@%@", CHANNEL_PREFIX, did]];
}

- (void)bindToChannelEvent:(NSString *)event handler:(void(^)(AMBPTPusherEvent *))handler {
    [self.channel bindToEventNamed:event handleWithBlock:handler];
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
    request = [self modifyPusherAuthRequest:request ambassadorKey:self.universalToken];
    NSMutableDictionary *httpBody = AMBparseQueryString([[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding]);
    pusherAuthObj.auth_type = @"private";
    pusherAuthObj.socket_id = httpBody[@"socket_id"];
    pusherAuthObj.channel = channel.name;
    NSError *e;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:[pusherAuthObj dictionaryForm] options:0 error:&e];
    if (e) {
        [self throwComletion:nil error:e];
    } else {
        request.HTTPBody = bodyData;
    }
}

- (NSMutableURLRequest *)modifyPusherAuthRequest:(NSMutableURLRequest *)request ambassadorKey:(NSString *)key {
    [request setValue:key forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (void)pusher:(AMBPTPusher *)pusher didFailToSubscribeToChannel:(AMBPTPusherChannel *)channel withError:(NSError *)error {
    [self throwComletion:channel error:error];
}

- (void)pusher:(AMBPTPusher *)pusher didSubscribeToChannel:(AMBPTPusherChannel *)channel {
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
