//
//  EventObject.m
//  test
//
//  Created by Diplomat on 6/4/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

- (id)init
{
    if ([super init])
    {
        self.parameter = [[NSString alloc] init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init])
    {
        self.parameter = [aDecoder decodeObjectForKey:@"parameter"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parameter forKey:@"parameter"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Parameter: %@", self.parameter];
}

@end
