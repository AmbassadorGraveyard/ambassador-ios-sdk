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
@property (nonatomic, strong) NSDictionary *fingerprint;

- (void)fillWithUrl:(NSString *)url completion:(void(^)(NSString *error))completion;
- (void)fillWithDictionary:(NSMutableDictionary *)d completion:(void(^)())completion;
- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber*)cID;

@end


#pragma mark - Identify Object

@interface AMBIdentifyNetworkObject : AMBNetworkObject

@property (nonatomic, strong) NSString * remote_customer_id;
@property (nonatomic, strong) NSString *campaign_id;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSDictionary *fp;
@property BOOL enroll;

// Traits
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSString * custom1;
@property (nonatomic, strong) NSString * custom2;
@property (nonatomic, strong) NSString * custom3;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * add_to_groups;
@property (nonatomic, strong) NSString * identify_type; // This trait should not be displayed to any user
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSString * country;
@property (nonatomic) BOOL sandbox;

- (instancetype)initWithUserID:(NSString *)userID traits:(NSDictionary *)traits;

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




