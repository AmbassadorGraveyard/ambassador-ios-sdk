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
#import "Sentry.h"


@implementation AMBNetworkObject


#pragma mark - Helper Functions

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

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    NSString *reason = [NSString stringWithFormat:@"The key \"%@\" does not exist.", key];
    SentryException *exception = [[SentryException alloc] initWithValue:reason type:@"Uknown key exception"];
    NSArray <SentryException *> *exceptions = @[exception];
    SentryEvent *event = [[SentryEvent alloc] initWithLevel:kSentrySeverityError];
    event.message = reason;
    event.exceptions = exceptions;
    
    [SentryClient.sharedClient sendEvent:event withCompletionHandler:nil];
}

- (void)fillWithDictionary:(NSMutableDictionary *)dictionary {
    [self setValuesForKeysWithDictionary:dictionary];
}

- (NSData*)toData {
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:&error];
}

@end


#pragma mark - Pusher Auth Object

@implementation AMBPusherAuthNetworkObject

- (instancetype)init {
    self =[super init];
    self.auth_type = @"";
    self.channel = @"";
    self.socket_id = @"";
    
    return self;
}

@end


#pragma mark - AMBUserNetworkObject

@implementation AMBUserUrlNetworkObject

// Decodes the object if saved to defaults
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.campaign_uid = [aDecoder decodeObjectForKey:@"campaign_uid"];
        self.short_code = [aDecoder decodeObjectForKey:@"short_code"];
        self.subject = [aDecoder decodeObjectForKey:@"subject"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.has_access = [aDecoder decodeBoolForKey:@"has_access"];
        self.is_active = [aDecoder decodeBoolForKey:@"is_active"];
    }
    
    return self;
}

// Encodes the object for saving to defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.campaign_uid forKey:@"campaign_uid"];
    [encoder encodeObject:self.short_code forKey:@"short_code"];
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeBool:self.has_access forKey:@"has_access"];
    [encoder encodeBool:self.is_active forKey:@"is_active"];
}

// Initializer from dictionary object
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


#pragma mark - User Object

@implementation AMBUserNetworkObject

// Decodes the object if saved to defaults
- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.email = [decoder decodeObjectForKey:@"email"];
        self.first_name = [decoder decodeObjectForKey:@"first_name"];
        self.last_name = [decoder decodeObjectForKey:@"last_name"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.uid = [decoder decodeObjectForKey:@"uid"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.urls = [decoder decodeObjectForKey:@"urls"];
        self.fingerprint = [decoder decodeObjectForKey:@"fingerprint"];
    }
    
    return self;
}

// Encodes the object for saving to defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.first_name forKey:@"first_name"];
    [encoder encodeObject:self.last_name forKey:@"last_name"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.uid forKey:@"uid"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.urls forKey:@"urls"];
    [encoder encodeObject:self.fingerprint forKey:@"fingerprint"];
}

// Used if pusher payload is too big to get back and only external url is given back
- (void)fillWithUrl:(NSString *)url completion:(void(^)(NSString *error))completion {
    [[AMBNetworkManager sharedInstance] getLargePusherPayloadFromUrl:url success:^(NSDictionary *response) {
        [self fillWithDictionary:(NSMutableDictionary*)response completion:^{
            completion(nil);
        }];
    } failure:^(NSString *error) {
        completion(error);
    }];
}

// Override fillWithDictionary because we set a custom object -- AMBUserUrlNetworkObject
- (void)fillWithDictionary:(NSMutableDictionary *)d completion:(void(^)())completion {
    NSMutableDictionary *bodyDict = (d[@"body"]) ? d[@"body"] : d;
    self.email = bodyDict[@"email"];
    self.first_name = bodyDict[@"first_name"];
    self.last_name = bodyDict[@"last_name"];
    self.phone = bodyDict[@"phone"];
    self.uid = bodyDict[@"uid"];
    self.url = bodyDict[@"url"];
    self.fingerprint = bodyDict[@"fingerprint"];
    self.urls = [[NSMutableArray alloc] init];
    
    NSArray *urls = bodyDict[@"urls"];
    for (NSMutableDictionary *url in urls) {
        AMBUserUrlNetworkObject *urlObj = [[AMBUserUrlNetworkObject alloc] init];
        [urlObj fillWithDictionary:url];
        [self.urls addObject:urlObj];
        
        if ([urls indexOfObject:url] == ([urls count] -1)) {
            completion();
        }
    }
}

- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber *)cID {
    for (AMBUserUrlNetworkObject *url in self.urls) {
        if ([url.campaign_uid isEqual:cID]) { return url; }
    }
    
    return nil;
}

@end


#pragma mark - Identify Object

@implementation AMBIdentifyNetworkObject

// Decodes the object if saved to defaults
- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.campaign_id = [decoder decodeObjectForKey:@"campaign_id"];
        self.source = [decoder decodeObjectForKey:@"source"];
        self.enroll = [decoder decodeBoolForKey:@"enroll"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.first_name = [decoder decodeObjectForKey:@"first_name"];
        self.last_name = [decoder decodeObjectForKey:@"last_name"];
        self.custom1 = [decoder decodeObjectForKey:@"custom1"];
        self.custom2 = [decoder decodeObjectForKey:@"custom2"];
        self.custom3 = [decoder decodeObjectForKey:@"custom3"];
        self.add_to_groups = [decoder decodeObjectForKey:@"add_to_groups"];
        self.identify_type = [decoder decodeObjectForKey:@"identify_type"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.company = [decoder decodeObjectForKey:@"company"];
        self.street = [decoder decodeObjectForKey:@"street"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.state = [decoder decodeObjectForKey:@"state"];
        self.zip = [decoder decodeObjectForKey:@"zip"];
        self.country = [decoder decodeObjectForKey:@"country"];
        self.remote_customer_id = [decoder decodeObjectForKey:@"remote_customer_id"];
    }
    
    return self;
}

// Encodes the object for saving to defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.campaign_id forKey:@"campaign_id"];
    [encoder encodeObject:self.source forKey:@"source"];
    [encoder encodeBool:self.enroll forKey:@"enroll"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.first_name forKey:@"first_name"];
    [encoder encodeObject:self.last_name forKey:@"last_name"];
    [encoder encodeObject:self.custom1 forKey:@"custom1"];
    [encoder encodeObject:self.custom2 forKey:@"custom2"];
    [encoder encodeObject:self.custom3 forKey:@"custom3"];
    [encoder encodeObject:self.add_to_groups forKey:@"add_to_groups"];
    [encoder encodeObject:self.identify_type forKey:@"identify_type"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.company forKey:@"company"];
    [encoder encodeObject:self.street forKey:@"street"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.zip forKey:@"zip"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.remote_customer_id forKey:@"remote_customer_id"];
}

- (instancetype)init {
    self = [super init];
    self.email = @"";
    self.campaign_id = @"";
    self.enroll = NO;
    self.source = @"ios_sdk_pilot";
    self.identify_type = @"";
    
    return self;
}

- (instancetype)initWithUserID:(NSString *)userID traits:(NSDictionary *)traits {
    // Initializes identify object and sets values
    if (self = [super init]) {
        self.remote_customer_id = userID;
        self.enroll = NO;
        self.campaign_id = @"";
        self.source = @"ios_sdk_pilot";
        self.identify_type = @"";
        [self formatTraits:traits];
        
        DLog(@"[Identify] Identifying with set properties -\n%@", [self toDictionary]);
    }
    
    return self;
}

- (void)formatTraits:(NSDictionary *)traits {
    NSString *blankString = @"";
    
    // Sets values of identify object if the matching trait is set in the dictionary
    self.email = traits[@"email"] ? traits[@"email"] : blankString;
    self.first_name = traits[@"firstName"] ? traits[@"firstName"] : blankString;
    self.last_name = traits[@"lastName"] ? traits[@"lastName"] : blankString;
    self.custom1 = traits[@"customLabel1"] ? traits[@"customLabel1"] : blankString;
    self.custom2 = traits[@"customLabel2"] ? traits[@"customLabel2"] : blankString;
    self.custom3 = traits[@"customLabel3"] ? traits[@"customLabel3"] : blankString;
    self.company = traits[@"company"] ? traits[@"company"] : blankString;
    self.add_to_groups = traits[@"addToGroups"] ? traits[@"addToGroups"] : blankString;
    self.identify_type = traits[@"identifyType"] ? traits[@"identifyType"] : blankString;
    self.street = traits[@"address"][@"street"] ? traits[@"address"][@"street"] : blankString;
    self.city = traits[@"address"][@"city"] ? traits[@"address"][@"city"] : blankString;
    self.state = traits[@"address"][@"state"] ? traits[@"address"][@"state"] : blankString;
    self.zip = traits[@"address"][@"postalCode"] ? traits[@"address"][@"postalCode"] : blankString;
    self.country = traits[@"address"][@"country"] ? traits[@"address"][@"country"] : blankString;
    self.phone = traits[@"phone"] ? traits[@"phone"] : blankString;
}

@end


#pragma mark - Share Track Object

@implementation AMBShareTrackNetworkObject

-(instancetype)init {
    self = [super init];
    self.recipient_username = @"";
    self.recipient_email = @"";
    self.short_code = @"";
    self.social_name = @"";
    self.from_email =  ([AMBValues getUserEmail]) ? [AMBValues getUserEmail] : @"";
    
    return self;
}

@end


#pragma mark - AMBBulkShareEmailObject

@implementation AMBBulkShareEmailObject

- (instancetype)initWithEmails:(NSArray*)emails message:(NSString*)message {
    self = [super init];
    self.to_emails = [[NSArray alloc] initWithArray:emails];
    self.short_code = [AMBValues getUserURLObject].short_code;
    self.message = message;
    self.subject_line = [AMBValues getUserURLObject].subject;
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


#pragma mark - Update Name Object

@implementation AMBUpdateNameObject

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email {
    self = [super init];
    self.update_data = [[NSDictionary alloc] initWithObjectsAndKeys:firstName, @"first_name", lastName, @"last_name", nil];
    self.email = email;
    
    return self;
}

@end


#pragma mark - Update APN Token Object

@implementation AMBUpdateAPNTokenObject

- (instancetype)initWithAPNDeviceToken:(NSString *)apnToken {
    self = [super init];
    self.update_data = @{@"apnToken" : apnToken};
    self.email = ([AMBValues getUserEmail]) ? [AMBValues getUserEmail] : @"";
    
    return self;
}

@end
