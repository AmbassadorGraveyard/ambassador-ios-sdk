//
//  Promise.m
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Promise.h"

@interface Promise ()

@property NSMutableArray *pending;
@property BOOL rejected;

@end


@implementation Promise


+ (Promise *)defer
{
    return [[Promise alloc] init];
}

- (void)resolve
{
        for (void (^f)(void) in self.pending) {
            if (self.rejected) {
                //[self fail];
                break;
            }
            f();
        }
        
        if (self.rejected) {
            //[self fail];
        }

}

- (void)reject
{
    self.rejected = YES;
}

- (Promise *)then:(void (^)(void))success
{
    [self.pending addObject:success];
    return self;
}

- (Promise *)fail:(void (^)(void))fail
{
    return self;
}

@end
