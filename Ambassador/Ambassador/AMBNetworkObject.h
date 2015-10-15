//
//  AMBNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBNetworkObject : NSObject
- (NSMutableDictionary *)toDictionary;
- (NSError *)validate;
- (void)fillWithDictionary:(NSMutableDictionary *)dictionary;
- (NSData *)toDataError:(NSError *__autoreleasing*)e;
@end



@interface AMBPusherSessionSubscribeNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *channel_name;
@property (nonatomic, strong) NSString *client_session_uid;
@property (nonatomic, strong) NSString *expires_at;
- (NSDate *)expires_at;
@end
