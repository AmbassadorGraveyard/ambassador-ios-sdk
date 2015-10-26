//
//  AMBPusherManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBPusherManager.h"
#import "AMBTests.h"

@interface AMBPusherManagerTests : AMBTests
@property NSString *channelName;
@end

@implementation AMBPusherManagerTests

- (void)setUp {
    [super setUp];
    self.channelName = @"test_channel";
}

- (void)tearDown {
    [super tearDown];
}

@end
