//
//  AMBPusherAuthNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBPusherAuthNetworkObject.h"

@implementation AMBPusherAuthNetworkObject
- (instancetype)init {
    if (self = [super init]) {
        self.auth_type = @"private";
        self.channel = @"";
        self.socket_id = @"";
    }
    return self;
}
@end
