//
//  AMBNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBNetworkObject : NSObject <NSCoding>
- (NSMutableDictionary *)toDictionary;
- (NSError *)validate;
- (void)fillWithDictionary:(NSMutableDictionary *)dictionary;
- (NSData *)toDataError:(NSError *__autoreleasing*)e;
- (void)save;
+ (instancetype)loadFromDisk;
@end



@interface AMBPusherSessionSubscribeNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *channel_name;
@property (nonatomic, strong) NSString *client_session_uid;
@property (nonatomic, strong) NSDate *expires_at;
- (BOOL)isExpired;
- (NSMutableDictionary *)additionalNetworkHeaders;
@end



@interface AMBPusherAuthNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *auth_type;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *socket_id;
@end



@interface AMBUserUrlNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSNumber *campaign_uid;
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *url;
@property BOOL has_access;
@property BOOL is_active;
@end



@interface AMBUserNetworkObject : AMBNetworkObject
- (void)fillWithUrl:(NSString *)url universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableArray *urls;

- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber*)cID;
@end



@interface AMBIdentifyNetworkObject : AMBNetworkObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *campaign_id;
@property BOOL enroll;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSMutableDictionary *fp;
@end
