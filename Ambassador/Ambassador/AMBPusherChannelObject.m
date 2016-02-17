//
//  AMBPusherChannelObject.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBPusherChannelObject.h"
#import "AMBUtilities.h"
#import "AmbassadorSDK_Internal.h"

@implementation AMBPusherChannelObject

- (instancetype)initWithDictionary:(NSMutableDictionary*)payloadDict {
    self.channelName = (NSString *)payloadDict[@"channel_name"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    self.expiresAt = [df dateFromString:(NSString *)payloadDict[@"expires_at"]];
    self.sessionId = (NSString *)payloadDict[@"client_session_uid"];
    
    return self;
}

- (void)createObjectFromDictionary:(NSMutableDictionary *)payloadDic {
    self.channelName = (NSString *)payloadDic[@"channel_name"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    self.expiresAt = [df dateFromString:(NSString *)payloadDic[@"expires_at"]];
    self.sessionId = (NSString *)payloadDic[@"client_session_uid"];
}

- (BOOL)isExpired {
    if ([self.expiresAt timeIntervalSinceNow] < 0.0) {
        return YES;
    }
    return NO;
}

@end
