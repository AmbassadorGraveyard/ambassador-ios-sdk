//
//  AMBNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
/// JAKE property names need the same as the fields in the JSON when you send

///-----------------------------------------------------------------------------
/// @name AMBNetworkObject
///-----------------------------------------------------------------------------
@interface AMBNetworkObject : NSObject <NSCoding>
- (NSMutableDictionary *)toDictionary;
- (NSError *)validate;
- (void)fillWithDictionary:(NSMutableDictionary *)dictionary;
- (NSData *)toDataError:(NSError *__autoreleasing*)e;
- (void)save;
+ (instancetype)loadFromDisk;
+ (void)deleteFromDisk;
@end

///-----------------------------------------------------------------------------
/// @name AMBPusherSessionSubscribeNetworkObject
///-----------------------------------------------------------------------------
@interface AMBPusherSessionSubscribeNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *channel_name;
@property (nonatomic, strong) NSString *client_session_uid;
@property (nonatomic, strong) NSDate *expires_at;
- (BOOL)isExpired;
- (NSMutableDictionary *)additionalNetworkHeaders;
@end

///-----------------------------------------------------------------------------
/// @name AMBPusherAuthNetworkObject
///-----------------------------------------------------------------------------
@interface AMBPusherAuthNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *auth_type;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *socket_id;
@end

///-----------------------------------------------------------------------------
/// @name AMBUserUrlNetworkObject
///-----------------------------------------------------------------------------
@interface AMBUserUrlNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSNumber *campaign_uid;
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *url;
@property BOOL has_access;
@property BOOL is_active;
@end

///-----------------------------------------------------------------------------
/// @name AMBUserNetworkObject
///-----------------------------------------------------------------------------
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

///-----------------------------------------------------------------------------
/// @name AMBIdentifyNetworkObject
///-----------------------------------------------------------------------------
@interface AMBIdentifyNetworkObject : AMBNetworkObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *campaign_id;
@property BOOL enroll;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSMutableDictionary *fp;
@end


///-----------------------------------------------------------------------------
/// @name AMBConversionFields
///-----------------------------------------------------------------------------
@interface AMBConversionFields : AMBNetworkObject
@property (nonatomic, retain) NSNumber * mbsy_campaign;
@property (nonatomic, retain) NSString * mbsy_email;
@property (nonatomic, retain) NSString * mbsy_first_name;
@property (nonatomic, retain) NSString * mbsy_last_name;
@property (nonatomic, retain) NSNumber * mbsy_email_new_ambassador;
@property (nonatomic, retain) NSString * mbsy_uid;
@property (nonatomic, retain) NSString * mbsy_custom1;
@property (nonatomic, retain) NSString * mbsy_custom2;
@property (nonatomic, retain) NSString * mbsy_custom3;
@property (nonatomic, retain) NSNumber * mbsy_auto_create;
@property (nonatomic, retain) NSNumber * mbsy_revenue;
@property (nonatomic, retain) NSNumber * mbsy_deactivate_new_ambassador;
@property (nonatomic, retain) NSString * mbsy_transaction_uid;
@property (nonatomic, retain) NSString * mbsy_add_to_group_id;
@property (nonatomic, retain) NSString * mbsy_event_data1;
@property (nonatomic, retain) NSString * mbsy_event_data2;
@property (nonatomic, retain) NSString * mbsy_event_data3;
@property (nonatomic, retain) NSNumber * mbsy_is_approved;

- (NSError *)isValid;
@end

///-----------------------------------------------------------------------------
/// @name AMBConversionNetworkObject
///-----------------------------------------------------------------------------
@interface AMBConversionNetworkObject : AMBNetworkObject
@property NSMutableDictionary *fp;
@property AMBConversionFields *fields;
@end

///-----------------------------------------------------------------------------
/// @name AMBShareTrackNetworkObject
///-----------------------------------------------------------------------------
@interface AMBShareTrackNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSMutableArray *recipient_email;
@property (nonatomic, strong) NSString *social_name;
@property (nonatomic, strong) NSMutableArray *recipient_username;
@end
