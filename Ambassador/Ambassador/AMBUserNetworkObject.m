//
//  AMBUserNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBUserNetworkObject.h"
#import "AMBUserUrlNetworkObject.h"

@implementation AMBUserNetworkObject

- (instancetype)fillFrom:(NSMutableDictionary *)dictionary {
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:@"urls"]) {
            self.urls = [[NSMutableArray alloc] init];
            NSArray *urls = dictionary[@"urls"];
            for (NSDictionary *url in urls) {
                AMBUserUrlNetworkObject *tmp = [[AMBUserUrlNetworkObject alloc] init];
                [self.urls addObject:[tmp fillFrom:[NSMutableDictionary dictionaryWithDictionary:url]]];
            }
        } else {
            [self setValue:[dictionary valueForKey:key] forKey:key];
        }
    }
    return self;
}

- (NSMutableDictionary *)dictionaryForm {
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    unsigned int numProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numProperties);
    for (NSUInteger i = 0; i <numProperties; ++i) {
        objc_property_t property = propertyArray[i];
        NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
        if ([key isEqualToString:@"urls"]) {
            NSMutableArray *urls = [self valueForKey:key];
            NSMutableArray *tmpUrls = [[NSMutableArray alloc] init];
            for (AMBUserUrlNetworkObject *url in urls) {
                [tmpUrls addObject:[url dictionaryForm]];
            }
            [returnDictionary setValue:tmpUrls forKey:key];
        } else {
            [returnDictionary setValue:[self valueForKey:key] forKey:key];
        }
    }
    return returnDictionary;
}

@end
