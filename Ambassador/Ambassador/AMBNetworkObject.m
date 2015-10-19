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
#import "AMBAmbassadorNetworkManager.h"

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
    NSLog(@"%@", NSStringFromClass([self class]));
    [NSKeyedArchiver archiveRootObject:self toFile:[[self rootPath] stringByAppendingPathComponent:NSStringFromClass([self class])]];
}

+ (instancetype)loadFromDisk {
    NSLog(@"%@", NSStringFromClass([self class]));
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])]];
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
@end



@implementation AMBPusherAuthNetworkObject
@end



@implementation AMBUserUrlNetworkObject
- (void)fillWithDictionary:(NSMutableDictionary *)d {
    self.campaign_uid = (NSNumber *)d[@"campaign_uid"];
    self.short_code = (NSString *)d[@"short_code"];
    self.subject = (NSString *)d[@"subject"];
    self.url = (NSString *)d[@"url"];
    self.has_access = (BOOL)d[@"has_access"];
    self.is_active = (BOOL)d[@"is_active"];
}
@end

@implementation AMBUserNetworkObject
- (void)fillWithUrl:(NSString *)url universalToken:(NSString *)uTok universalID:(NSString *)uID completion:(void(^)(NSError *))c {
    __weak AMBUserNetworkObject *weakSelf = self;
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:url universalToken:uTok universalID:uID additionParams:nil completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) {
            if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
        } else {
            NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:&e];
            if (e) {
                if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(e); }); }
            } else {
                [weakSelf fillWithDictionary:json];
                if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(nil); }); }
            }
        }
    }];
}

- (void)fillWithDictionary:(NSMutableDictionary *)d {
    self.email = AMBStringValFromDictionary(d, @"email");
    self.first_name = AMBStringValFromDictionary(d, @"first_name");
    self.last_name = AMBStringValFromDictionary(d, @"last_name");
    self.phone = AMBStringValFromDictionary(d, @"phone");
    self.uid = AMBStringValFromDictionary(d, @"uid");
    self.url = AMBStringValFromDictionary(d, @"url");
    self.urls = [[NSMutableArray alloc] init];
    
    NSArray *urls = AMBArrayFromDicstionary(d, @"urls");
    for (NSMutableDictionary *url in urls) {
        AMBUserUrlNetworkObject *urlObj = [[AMBUserUrlNetworkObject alloc] init];
        [urlObj fillWithDictionary:url];
        [self.urls addObject:urlObj];
    }
}

- (AMBUserUrlNetworkObject *)urlObjForCampaignID:(NSNumber *)cID {
    for (AMBUserUrlNetworkObject *url in self.urls) {
        if ([url.campaign_uid isEqual:cID]) {
            return url;
        }
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
