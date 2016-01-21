//
//  AMBNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <objc/runtime.h>
#import "AMBNetworkObject.h"
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

- (void)fillWithDictionary:(NSMutableDictionary *)dictionary {
    [self setValuesForKeysWithDictionary:dictionary];
}

- (NSData*)toData {
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:&error];
}

@end



@implementation AMBPusherAuthNetworkObject
@end


#pragma mark - AMBUserNetworkObject

@implementation AMBUserUrlNetworkObject

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
