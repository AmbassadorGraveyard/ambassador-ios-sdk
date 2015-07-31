//
//  Contact.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Contact.h"

@implementation Contact

#pragma mark - Initialization
- (id)init
{
    if ([super init])
    {
        self.firstName = @"";
        self.lastName = @"";
        self.label = @"";
        self.value = @"";
    }
    
    return self;
}



#pragma mark - Concat Name
- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}



#pragma mark - Overrides for NSSet Storage
//
// [NSSet memeber:(id)obj] will test for equality by calling the obj's
// isEqual: method. To test for equality it compares the hash which is
// set equal to the value key of the contact which is unique due to NSMutableSet
// adhearing to strict set requirements. This makes the contacts's value
// deterministic.
//
- (BOOL)isEqual:(id)object
{
    Contact *obj = (Contact *)object;
    return [self.value isEqualToString:obj.value];
}

- (NSUInteger)hash
{
    return [self.value intValue];
}

@end
