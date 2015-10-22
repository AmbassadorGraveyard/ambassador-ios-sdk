//
//  AMBPusherChannelObject.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBPusherChannelObject.h"

@implementation AMBPusherChannelObject

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

- (NSMutableDictionary *)createAdditionalNetworkHeaders {
    NSMutableDictionary *returnVal = [[NSMutableDictionary alloc] init];
    [returnVal setValue:self.sessionId forKey:@"X-Mbsy-Client-Session-ID"];
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    [returnVal setValue:timestamp forKey:@"X-Mbsy-Client-Request-ID"];
    return returnVal;
}

@end
