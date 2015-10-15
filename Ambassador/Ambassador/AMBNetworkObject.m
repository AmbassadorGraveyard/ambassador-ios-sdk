//
//  AMBNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <objc/runtime.h>
#import "AMBNetworkObject.h"

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
@end



@implementation AMBPusherSessionSubscribeNetworkObject
@synthesize expires_at = _expires_at;

- (NSDate *)expires_at {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    NSDate *myDate = [df dateFromString: _expires_at];
    return myDate;
}
@end

