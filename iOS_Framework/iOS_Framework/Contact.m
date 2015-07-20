//
//  Contact.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Contact.h"
#import "Constants.h"

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

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

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
