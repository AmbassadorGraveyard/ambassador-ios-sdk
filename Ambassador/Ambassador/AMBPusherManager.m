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
#import "AMBSecrets.h"

@interface AMBPusherManager () <AMBPTPusherDelegate>

@property (nonatomic, strong) AMBPTPusher *client;
@property (nonatomic, strong) AMBPTPusherPrivateChannel *channel;
@property (nonatomic, copy) void (^completion)(AMBPTPusherChannel *pusherChannel, NSError *error);
@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic) BOOL campaignListRecieved;

@end


@implementation AMBPusherManager

+ (NSString *)pusherKey {
#if AMBPRODUCTION
    return [AMBSecrets secretForKey:AMB_PUSHER_PROD_KEY];
#else
    return [AMBSecrets secretForKey:AMB_PUSHER_DEV_KEY];
#endif
}


#pragma mark - Initialization

- (instancetype)initWithAuthorization:(NSString *)auth {
    if (self = [super init]) {
        self.universalToken = auth;
        self.client = [AMBPTPusher pusherWithKey:[AMBPusherManager pusherKey] delegate:self encrypted:YES];
        self.client.authorizationURL = [NSURL URLWithString:[AMBValues getPusherAuthUrl]];
        self.connectionState = PTPusherConnectionDisconnected;
    }
    
    return self;
}

- (void)subscribeToChannel:(NSString *)channel completion:(void(^)(AMBPTPusherChannel *pusherChannel, NSError *error))completion {
    self.completion = completion;
    
    // Connect/Reconnect the client which should be disconnected from previously
    [self.client connect];
    
    // Subscribe to our new channel
    self.channel = [self.client subscribeToPrivateChannelNamed:channel];
}

- (void)resubscribeToExistingChannelWithCompletion:(void(^)(AMBPTPusherChannel *, NSError *))completion {
    NSString *channelName = [AMBValues getPusherChannelObject].channelName;
    self.completion = completion;
    
    if (channelName && ![channelName isEqualToString:@""]) {
        self.channel = [self.client subscribeToPrivateChannelNamed:[AMBValues getPusherChannelObject].channelName];
        self.completion(self.channel, nil);
    } else {
        self.completion(self.channel, [NSError errorWithDomain:@"Could not find existing channel name to subscribe!" code:1 userInfo:nil]);
    }
}

- (void)bindToChannelEvent:(NSString*)eventName {
    [self.channel bindToEventNamed:eventName handleWithBlock:^(AMBPTPusherEvent *event) {
        NSMutableDictionary *json = (NSMutableDictionary *)event.data[@"body"];
        AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
        if (event.data[@"url"]) {
            // Attempts to close socket
            [self receivedIdentifyAction];
            [user fillWithUrl:event.data[@"url"] completion:^(NSString *error) {
                if (!error) {
                    [AMBValues setUserCampaignList:user];
                    [AMBValues setUserFirstNameWithString:user.first_name];
                    [AMBValues setUserLastNameWithString:user.last_name];
                    if (user.fingerprint){
                        NSLog(@"User Fingerprint exists");
                        NSLog(@"%@", user.fingerprint);
                        [AMBValues setDeviceFingerPrintWithDictionary:user.fingerprint]; // Saves device fp to defaults
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
                }
            }];
        } else if (json[@"mbsy_cookie_code"] && json[@"mbsy_cookie_code"] != [NSNull null]) {
            NSLog(@"[Identify] Short code '%@' and fingerprint recieved.", json[@"mbsy_cookie_code"]);
            [AMBValues setMbsyCookieWithCode:json[@"mbsy_cookie_code"]]; // Saves mbsy cookie to defaults
            NSDictionary *consumerDict = @{@"UID" : json[@"fingerprint"][@"consumer"][@"UID"]};
            NSDictionary *deviceDict = @{@"type" : json[@"fingerprint"][@"device"][@"type"], @"ID" : json[@"fingerprint"][@"device"][@"ID"]};
            NSDictionary *fingerPrintDict = @{@"consumer" : consumerDict, @"device" : deviceDict };
            [AMBValues setDeviceFingerPrintWithDictionary:fingerPrintDict]; // Saves device fp to defaults
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceInfoReceived" object:nil];
            
        } else if (!json[@"uid"] && json[@"fingerprint"] && json[@"fingerprint"] != [NSNull null]) {
            NSLog(@"[Identify] fingerprint recieved.");
            NSDictionary *consumerDict = @{@"UID" : json[@"fingerprint"][@"consumer"][@"UID"]};
            NSDictionary *deviceDict = @{@"type" : json[@"fingerprint"][@"device"][@"type"], @"ID" : json[@"fingerprint"][@"device"][@"ID"]};
            NSDictionary *fingerPrintDict = @{@"consumer" : consumerDict, @"device" : deviceDict };
            [AMBValues setDeviceFingerPrintWithDictionary:fingerPrintDict]; // Saves device fp to defaults
            [self receivedIdentifyAction];
            NSLog(@"FP DICT: %@", fingerPrintDict);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceInfoReceived" object:nil];
        }else {
            NSLog(@"[Identify] no url, cookie, or fingerprint.");
            // Attempts to close socket
            [self receivedIdentifyAction];
            [user fillWithDictionary:json completion:^{
                // Set the user object with campaign list in defaults
                [AMBValues setUserCampaignList:user];
                [AMBValues setUserFirstNameWithString:user.first_name];
                [AMBValues setUserLastNameWithString:user.last_name];
                if (user.fingerprint){
                    [AMBValues setDeviceFingerPrintWithDictionary:user.fingerprint]; // Saves device fp to defaults
                }else if ((json[@"fingerprint"] && json[@"fingerprint"] != [NSNull null])){
                    NSDictionary *consumerDict = @{@"UID" : json[@"fingerprint"][@"consumer"][@"UID"]};
                    NSDictionary *deviceDict = @{@"type" : json[@"fingerprint"][@"device"][@"type"], @"ID" : json[@"fingerprint"][@"device"][@"ID"]};
                    NSDictionary *fingerPrintDict = @{@"consumer" : consumerDict, @"device" : deviceDict };
                    [AMBValues setDeviceFingerPrintWithDictionary:fingerPrintDict]; // Saves device fp to defaults
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PusherReceived" object:nil];
            }];
        }
    }];
}

- (void)receivedIdentifyAction {
    self.campaignListRecieved = YES;
    [self closeSocket];
}

- (void)closeSocket {
    // Checks to make sure we have finished the backend identify request and safariVC fingerprinting before closing the channel
    if (self.campaignListRecieved && [AmbassadorSDK sharedInstance].identify.identifyProcessComplete) {
        DLog(@"[Identify] Identify process complete, Pusher client disconnected.");
        [self.client disconnect];
        
        // If there is an existing channel, we need to unsubscribe in order to avoid duplicate event actions
        if (self.channel) { [self.channel unsubscribe]; }
        
        // Sets our pusher channel objec to nil to avoid unauthorized re-use 
        [AMBValues setPusherChannelObject:nil];
        
        // Sets flag to tell that we're done identifying
        [AmbassadorSDK sharedInstance].identifyInProgress = NO;
        
        // Attempts to send unsent conversions now that we would have the shortCode/fingerprint if referred
        [[AmbassadorSDK sharedInstance].conversion retryUnsentConversions];
    }
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
    self.connectionState = PTPusherConnectionConnected;
}

- (BOOL)pusher:(AMBPTPusher *)pusher connectionWillAutomaticallyReconnect:(AMBPTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    return YES;
}

- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection failedWithError:(NSError *)error {
    // FUNCTIONALITY: Lets pusherManager know when the pusher socket has been DISCONNECTED
    self.connectionState = PTPusherConnectionDisconnected;
}

- (void)pusher:(AMBPTPusher *)pusher connection:(AMBPTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
    // FUNCTIONALITY: Lets pusherManager know when the pusher socket has been DISCONNECTED
    self.connectionState = PTPusherConnectionDisconnected;
}

@end
