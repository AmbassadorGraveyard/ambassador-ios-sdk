//
//  AMBNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <objc/runtime.h>
#import "AMBNetworkObject.h"
#import "AMBUtilities.h"
#import "AMBNetworkManager.h"

@implementation AMBNetworkObject
- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    unsigned int numProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numProperties);
    for (NSUInteger i = 0; i <numProperties; ++i) {
        objc_property_t property = propertyArray[i];
        NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [returnDictionary setValue:[self valueForKey:key] forKey:key];
    }
    return returnDictionary;
}

- (NSError *)validate { return nil; }

- (void)fillWithDictionary:(NSMutableDictionary *)dictionary {
    [self setValuesForKeysWithDictionary:dictionary];
}

- (NSData *)toDataError:(NSError *__autoreleasing*)e {
    return [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:e];
}

- (NSData*)toData {
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:&error];
}



#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int numProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numProperties);
    for (NSUInteger i = 0; i <numProperties; ++i) {
        objc_property_t property = propertyArray[i];
        NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int numProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numProperties);
        for (NSUInteger i = 0; i <numProperties; ++i) {
            objc_property_t property = propertyArray[i];
            NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}



#pragma mark - storage
- (NSString *)rootPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[[self rootPath] stringByAppendingPathComponent:NSStringFromClass([self class])]];
}

+ (instancetype)loadFromDisk {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])]];
}

+ (void)deleteFromDisk {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:rootPath error:&error];
}

@end



@implementation AMBPusherSessionSubscribeNetworkObject
- (void)fillWithDictionary:(NSMutableDictionary *)d {
    self.channel_name = (NSString *)d[@"channel_name"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    self.expires_at = [df dateFromString:(NSString *)d[@"expires_at"]];
    self.client_session_uid = (NSString *)d[@"client_session_uid"];
}

- (BOOL)isExpired {
    if ([self.expires_at timeIntervalSinceNow] < 0.0) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)additionalNetworkHeaders {
    NSMutableDictionary *returnVal = [[NSMutableDictionary alloc] init];
    [returnVal setValue:self.client_session_uid forKey:@"X-Mbsy-Client-Session-ID"];
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    [returnVal setValue:timestamp forKey:@"X-Mbsy-Client-Request-ID"];
    return returnVal;
}
@end



@implementation AMBPusherAuthNetworkObject
@end


#pragma mark - AMBUserNetworkObject

@implementation AMBUserUrlNetworkObject

- (void)fillWithDictionary:(NSMutableDictionary *)d {
    self.campaign_uid = (NSNumber *)d[@"campaign_uid"];
    self.short_code = (NSString *)d[@"short_code"];
    self.subject = (NSString *)d[@"subject"];
    self.url = (NSString *)d[@"url"];
    self.has_access = (BOOL)d[@"has_access"];
    self.is_active = (BOOL)d[@"is_active"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self.campaign_uid = (NSNumber *)dict[@"campaign_uid"];
    self.short_code = (NSString *)dict[@"short_code"];
    self.subject = (NSString *)dict[@"subject"];
    self.url = (NSString *)dict[@"url"];
    self.has_access = (BOOL)dict[@"has_access"];
    self.is_active = (BOOL)dict[@"is_active"];
    
    return self;
}

@end



@implementation AMBUserNetworkObject

- (void)fillWithUrl:(NSString *)url completion:(void(^)(NSString *error))completion {
    [[AMBNetworkManager sharedInstance] getLargePusherPayloadFromUrl:url success:^(NSDictionary *response) {
        [self fillWithDictionary:(NSMutableDictionary*)response];
        completion(nil);
    } failure:^(NSString *error) {
        completion(error);
    }];
}

- (void)fillWithDictionary:(NSMutableDictionary *)d {
    NSMutableDictionary *bodyDict = (d[@"body"]) ? d[@"body"] : d;
    self.email = bodyDict[@"email"];
    self.first_name = bodyDict[@"first_name"];
    self.last_name = bodyDict[@"last_name"];
    self.phone = bodyDict[@"phone"];
    self.uid = bodyDict[@"uid"];
    self.url = bodyDict[@"url"];
    self.urls = [[NSMutableArray alloc] init];
    
    NSArray *urls = bodyDict[@"urls"];
    for (NSMutableDictionary *url in urls) {
        AMBUserUrlNetworkObject *urlObj = [[AMBUserUrlNetworkObject alloc] init];
        [urlObj fillWithDictionary:url];
        [self.urls addObject:urlObj];
    }
}

- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber *)cID {
    for (AMBUserUrlNetworkObject *url in self.urls) {
        if ([url.campaign_uid isEqual:cID]) { return url; }
    }
    return nil;
}

@end



@implementation AMBIdentifyNetworkObject
- (instancetype)init {
    if (self = [super init]) {
        self.email = @"";
        self.campaign_id = @"";
        self.enroll = NO;
        self.source = @"";
    }
    return self;
}
@end



@implementation AMBShareTrackNetworkObject
-(instancetype)init {
    if (self = [super init]) {
        self.recipient_username = @"";
        self.recipient_email = @"";
        self.short_code = @"";
        self.social_name = @"";
        self.from_email =  ([AMBValues getUserEmail]) ? [AMBValues getUserEmail] : @"";
    }
    return self;
}
@end


#pragma mark - AMBBulkShareEmailObject

@implementation AMBBulkShareEmailObject

- (instancetype)initWithEmails:(NSArray*)emails shortCode:(NSString*)shortCode message:(NSString*)message subjectLine:(NSString*)subjectLine {
    self = [super init];
    self.to_emails = [[NSArray alloc] initWithArray:emails];
    self.short_code = shortCode;
    self.message = message;
    self.subject_line = subjectLine;
    self.from_email = ([AMBValues getUserEmail]) ? [AMBValues getUserEmail] : @"";
    
    return self;
}

@end


#pragma mark - AMBBulkShareSMSObject

@implementation AMBBulkShareSMSObject

- (instancetype)initWithPhoneNumbers:(NSArray*)phoneNumbers fromSender:(NSString*)sender message:(NSString*)message {
    self = [super init];
    self.to = [[NSArray alloc] initWithArray:phoneNumbers];
    self.name = sender;
    self.message = message;
    self.from_email = ([AMBValues getUserEmail]) ? [AMBValues getUserEmail] : @"";
    
    return self;
}

@end


#pragma mark - AMBUpdateNameObject

@implementation AMBUpdateNameObject

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email {
    self = [super init];
    self.update_data = [[NSDictionary alloc] initWithObjectsAndKeys:firstName, @"first_name",
                        lastName, @"last_name", nil];
    self.email = email;
    
    return self;
}

@end
