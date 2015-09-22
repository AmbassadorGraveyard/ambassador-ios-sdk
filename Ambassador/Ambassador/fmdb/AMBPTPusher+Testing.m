//
//  PTPusher+Testing.m
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusher+Testing.h"
#import "AMBPTPusherChannelAuthorizationOperation.h"

NSString *const AMBPTPusherAuthorizationBypassURL = @"libpusher://auth/bypass/url";

@implementation AMBPTPusher (Testing)

- (void)enableChannelAuthorizationBypassMode
{
  self.authorizationURL = [NSURL URLWithString:AMBPTPusherAuthorizationBypassURL];
}

@end
