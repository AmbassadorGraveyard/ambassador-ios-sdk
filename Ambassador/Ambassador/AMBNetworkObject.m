//
//  AMBNetworkObject.m
//  networking
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBNetworkObject.h"

@implementation AMBNetworkObject

- (NSMutableDictionary *)dictionaryForm {
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

- (instancetype)fillFrom:(NSMutableDictionary *)dictionary {
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys) {
        [self setValue:[dictionary valueForKey:key] forKey:key];
    }
    return self;
}

@end
