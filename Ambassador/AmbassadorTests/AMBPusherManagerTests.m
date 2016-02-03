//
//  AMBPusherManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBPusherManager.h"
#import "AMBTests.h"
#import "AMBPTPusher.h"

@interface AMBPusherManager (Test)

@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) AMBPTPusher *client;

- (instancetype)initWithAuthorization:(NSString *)auth;

@end


@interface AMBPusherManagerTests : XCTestCase

@property (nonatomic, strong) AMBPusherManager * pusherMgr;

@end

@implementation AMBPusherManagerTests

- (void)setUp {
    [super setUp];
    if (!self.pusherMgr) {
        self.pusherMgr = [AMBPusherManager sharedInstanceWithAuthorization:@"testAuth"];
    }
}

- (void)tearDown {
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testSharedInstance {
    XCTAssertNotNil(self.pusherMgr);
}


#pragma mark - Initialization Tests

- (void)testInitWithAuth {
    // GIVEN
    NSString *fakeToken = @"fakeToken123";
    
    // WHEN
    AMBPusherManager *mockMgr = [self.pusherMgr initWithAuthorization:fakeToken];
    
    // THEN
    XCTAssertEqualObjects(fakeToken, mockMgr.universalToken);
}

- (void)testSubscribeToChannel {
    // GIVEN
    NSString *channelName = @"fakeChannelName";
    id mockPusher = [OCMockObject mockForClass:[AMBPTPusher class]];
    self.pusherMgr.client = mockPusher;
    [[[mockPusher expect] andDo:nil] subscribeToPrivateChannelNamed:channelName];
    
    // WHEN
    [self.pusherMgr subscribeToChannel:channelName completion:nil];
    
    // THEN
    [mockPusher verify];
}

@end
