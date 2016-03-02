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


#pragma mark - Pusher Auth Object

@interface AMBPusherAuthNetworkObject : AMBNetworkObject

@property (nonatomic, strong) NSString *auth_type;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *socket_id;

@end


#pragma mark - URL Object

@interface AMBUserUrlNetworkObject : AMBNetworkObject

@property (nonatomic, strong) NSNumber *campaign_uid;
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *url;
@property BOOL has_access;
@property BOOL is_active;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end


#pragma mark - User Object

@interface AMBUserNetworkObject : AMBNetworkObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableArray *urls;

- (void)fillWithUrl:(NSString *)url completion:(void(^)(NSString *error))completion;
- (void)fillWithDictionary:(NSMutableDictionary *)d completion:(void(^)())completion;
- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber*)cID;

@end


#pragma mark - Identify Object

@interface AMBIdentifyNetworkObject : AMBNetworkObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *campaign_id;
@property BOOL enroll;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSDictionary *fp;

@end


#pragma mark - Share Track Object

@interface AMBShareTrackNetworkObject : AMBNetworkObject

@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *recipient_email;
@property (nonatomic, strong) NSString *social_name;
@property (nonatomic, strong) NSString *recipient_username;
@property (nonatomic, strong) NSString * from_email;

@end


#pragma mark - Bulk Share Email Object

@interface AMBBulkShareEmailObject : AMBNetworkObject

@property (nonatomic, strong) NSArray * to_emails;
@property (nonatomic, strong) NSString * short_code;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * subject_line;
@property (nonatomic, strong) NSString * from_email;

- (instancetype)initWithEmails:(NSArray*)emails message:(NSString*)message;

@end


#pragma mark - Bulk Share SMS Object

@interface AMBBulkShareSMSObject : AMBNetworkObject

@property (nonatomic, strong) NSArray * to;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * from_email;

- (instancetype)initWithPhoneNumbers:(NSArray*)phoneNumbers fromSender:(NSString*)sender message:(NSString*)message;

@end


#pragma mark - Name Update Object

@interface AMBUpdateNameObject : AMBNetworkObject

@property (nonatomic, strong) NSDictionary * update_data;
@property (nonatomic, strong) NSString * email;

- (instancetype)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;

@end

#pragma mark - APN Token Update Object

@interface AMBUpdateAPNTokenObject : AMBNetworkObject

@property (nonatomic, strong) NSDictionary * update_data;
@property (nonatomic, strong) NSString * email;

- (instancetype)initWithAPNDeviceToken:(NSString*)apnToken;

@end




