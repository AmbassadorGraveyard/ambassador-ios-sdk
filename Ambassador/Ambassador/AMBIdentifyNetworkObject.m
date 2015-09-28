//
//  AMBIdentifyNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBIdentifyNetworkObject.h"
#import "AMBErrors.h"


@implementation AMBIdentifyNetworkObject
- (instancetype)init {
    if (self = [super init]) {
        _email = @"";
        _campaign_id = @"";
        _enroll = YES;
        _source = @"ios_sdk_pilot";
        _fp = [NSMutableDictionary dictionaryWithDictionary:@{}];
    }
    return self;
}

- (NSError *)validate {
    if ([_email isEqualToString:@""] && [_fp isEqualToDictionary:@{}]) {
        return AMBINVETOBJError(self);
    }
    return nil;
}

@end
