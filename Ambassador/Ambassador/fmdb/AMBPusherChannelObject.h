//
//  AMBPusherChannelObject.h
//  Ambassador
//
//  Created by Jake Dunahee on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBPusherChannelObject : NSObject

@property (nonatomic, strong) NSString * channelName;
@property (nonatomic, strong) NSString * sessionId;
@property (nonatomic, strong) NSDate * expiresAt;
@property (nonatomic, strong) NSNumber * requestId;

- (void)createObjectFromDictionary:(NSMutableDictionary *)payloadDic;
- (BOOL)isExpired;
- (NSMutableDictionary *)createAdditionalNetworkHeaders;

@end
