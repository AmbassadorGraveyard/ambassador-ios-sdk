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
- (void)fillWithDictionary:(NSMutableDictionary *)dictionary;
- (NSData*)toData;

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

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end



@interface AMBUserNetworkObject : AMBNetworkObject
//- (void)fillWithUrl:(NSString *)url universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c;
- (void)fillWithUrl:(NSString *)url completion:(void(^)(NSString *error))completion;
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
@property (strong, nonatomic) NSDictionary *fp;
@end


// Bulk Share Network objects
@interface AMBShareTrackNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *recipient_email;
@property (nonatomic, strong) NSString *social_name;
@property (nonatomic, strong) NSString *recipient_username;
@property (nonatomic, strong) NSString * from_email;
@end

@interface AMBBulkShareEmailObject : AMBNetworkObject
@property (nonatomic, strong) NSArray * to_emails;
@property (nonatomic, strong) NSString * short_code;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * subject_line;
@property (nonatomic, strong) NSString * from_email;

- (instancetype)initWithEmails:(NSArray*)emails shortCode:(NSString*)shortCode message:(NSString*)message subjectLine:(NSString*)subjectLine;

@end

@interface AMBBulkShareSMSObject : AMBNetworkObject
@property (nonatomic, strong) NSArray * to;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * from_email;

- (instancetype)initWithPhoneNumbers:(NSArray*)phoneNumbers fromSender:(NSString*)sender message:(NSString*)message;

@end

@interface AMBUpdateNameObject : AMBNetworkObject

@property (nonatomic, strong) NSDictionary * update_data;
@property (nonatomic, strong) NSString * email;

- (instancetype)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;

@end


