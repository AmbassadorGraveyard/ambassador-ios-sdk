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
#import "AMBPTPusher.h"
#import "AMBValues.h"
#import "AmbassadorSDK_Internal.h"

@interface AMBPusherManager (Test) <AMBPTPusherDelegate>

@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) AMBPTPusher *client;
@property (nonatomic, copy) void (^completion)(AMBPTPusherChannel *pusherChannel, NSError *error);
@property (nonatomic, strong) AMBPTPusherPrivateChannel *channel;
@property (nonatomic) BOOL campaignListRecieved;

- (instancetype)initWithAuthorization:(NSString *)auth;
- (NSMutableURLRequest *)modifyPusherAuthRequest:(NSMutableURLRequest *)request authorization:(NSString *)auth;
- (void)throwComletion:(AMBPTPusherChannel *)channel error:(NSError *)error;
- (void)closeSocket;
- (void)receivedIdentifyAction;

@end


@interface AMBPusherManagerTests : XCTestCase

@property (nonatomic, strong) AMBPusherManager * pusherMgr;
@property (nonatomic) id mockPusherMgr;

@end

@implementation AMBPusherManagerTests

- (void)setUp {
    [super setUp];
    if (!self.pusherMgr) {
        self.pusherMgr = [[AMBPusherManager alloc] initWithAuthorization:@"fakeAuth"];
    }
    
    self.mockPusherMgr = [OCMockObject partialMockForObject:self.pusherMgr];
}

- (void)tearDown {
    [self.mockPusherMgr stopMocking];
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
    [[[mockPusher expect] andDo:nil] connect];
    
    // WHEN
    [self.pusherMgr subscribeToChannel:channelName completion:nil];
    
    // THEN
    [mockPusher verify];
}

- (void)testResubscribeToChannelSuccess {
    // GIVEN
    XCTestExpectation *expectation = [self expectationWithDescription:@"pusherCompletion"];
    
    NSString *channelName = @"asdfasdf";
    NSDictionary *mockDict = @{ @"channel_name" : channelName };
    [AMBValues setPusherChannelObject:mockDict];
    
    id mockPusher = [OCMockObject mockForClass:[AMBPTPusher class]];
    self.pusherMgr.client = mockPusher;
    [[[mockPusher expect] andDo:nil] subscribeToPrivateChannelNamed:channelName];
    [[mockPusher expect] andDo:^(NSInvocation *invocation) {
        void (^completion)(AMBPTPusherChannel *pusherChannel, NSError *error) = nil;
        [invocation getArgument:&completion atIndex:3];
        completion([OCMArg any], nil);
    }];
    
    // WHEN
    [self.pusherMgr resubscribeToExistingChannelWithCompletion:^(AMBPTPusherChannel *connection, NSError *error) {
        [expectation fulfill];
    }];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [mockPusher verify];
    }];
    
}

- (void)testResubscribeToChannelFail {
    // GIVEN
    XCTestExpectation *expectation = [self expectationWithDescription:@"pusherCompletion"];
    
    NSString *channelName = @"";
    NSDictionary *mockDict = @{ @"channel_name" : channelName };
    [AMBValues setPusherChannelObject:mockDict];
    
    id mockPusher = [OCMockObject mockForClass:[AMBPTPusher class]];
    self.pusherMgr.client = mockPusher;
    
    [[mockPusher expect] andDo:^(NSInvocation *invocation) {
        void (^completion)(AMBPTPusherChannel *pusherChannel, NSError *error) = nil;
        [invocation getArgument:&completion atIndex:3];
        completion([OCMArg any], [OCMArg any]);
    }];
    
    // WHEN
    [self.pusherMgr resubscribeToExistingChannelWithCompletion:^(AMBPTPusherChannel *connection, NSError *error) {
        [expectation fulfill];
    }];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [mockPusher verify];
    }];
    
}

- (void)testBindToChannel {
    // GIVEN
    self.pusherMgr.channel = [self.pusherMgr.client subscribeToPrivateChannelNamed:@"fakeChannel"];
    
    id mockChannel = [OCMockObject partialMockForObject:(NSObject*)self.pusherMgr.channel];
    [[[mockChannel expect] andDo:^(NSInvocation *invocation) {
        void (^handleWithBlock)(AMBPTPusherEvent *event) = nil;
        [invocation getArgument:&handleWithBlock atIndex:3];
        handleWithBlock(nil);
    }] bindToEventNamed:@"action" handleWithBlock:[OCMArg invokeBlock]];

    // WHEN
    [self.pusherMgr bindToChannelEvent:@"action"];
    
    // THEN
    [mockChannel verify];
}


#pragma mark - PTPusher Delegate Tests

- (void)testPusherWillAuthorize {
    // GIVEN
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"fakeurl.com"]];
    [[[self.mockPusherMgr expect] andDo:nil] modifyPusherAuthRequest:[OCMArg any] authorization:[OCMArg any]];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client willAuthorizeChannel:(AMBPTPusherChannel*)self.pusherMgr.channel withRequest:request];
    
    // THEN
    [self.mockPusherMgr verify];
}

- (void)testModifyPusherAuth {
    // GIVEN
    NSString *authString = @"fakeAuthString";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"fakeurl.com"]];
    id mockRequest = [OCMockObject partialMockForObject:request];
    [[[mockRequest expect] andDo:nil]  setValue:authString forHTTPHeaderField:@"Authorization"];
    [[[mockRequest expect] andDo:nil] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // WHEN
    [self.pusherMgr modifyPusherAuthRequest:request authorization:authString];
    
    // THEN
    [mockRequest verify];
}

- (void)testPusherDidFailToSubscribe {
    // GIVEN
    NSError *fakeError = [NSError errorWithDomain:@"fakedomain" code:1 userInfo:nil];
    [[[self.mockPusherMgr expect] andDo:nil] throwComletion:[OCMArg any] error:fakeError];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client didFailToSubscribeToChannel:(AMBPTPusherChannel*)self.pusherMgr.channel withError:fakeError];
    
    // THEN
    [self.mockPusherMgr verify];
}

- (void)testPusherDidSubscribe {
    // GIVEN
    [[[self.mockPusherMgr expect] andDo:nil] throwComletion:(AMBPTPusherChannel*)self.pusherMgr.channel error:nil];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client didSubscribeToChannel:(AMBPTPusherChannel*)self.pusherMgr.channel];
    
    // THEN
    [self.mockPusherMgr verify];
}

- (void)testPusherDidConnect {
    // GIVEN
    PTPusherConnectionState expectedState = PTPusherConnectionConnected;
    AMBPTPusherConnection *connection = [[AMBPTPusherConnection alloc] init];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client connectionDidConnect:connection];
    
    // THEN
    XCTAssertEqual(expectedState, self.pusherMgr.connectionState);
}

- (void)testPusherWillAutomaticallyReconnect {
    // GIVEN
    AMBPTPusherConnection *connection = [[AMBPTPusherConnection alloc] init];
    
    // WHEN
    BOOL returnValue = [self.pusherMgr pusher:self.pusherMgr.client connectionWillAutomaticallyReconnect:connection afterDelay:0];
    
    // THEN
    XCTAssertTrue(returnValue);
}

- (void)testPusherConnectionFailed {
    // GIVEN
    PTPusherConnectionState expectedState = PTPusherConnectionDisconnected;
    AMBPTPusherConnection *connection = [[AMBPTPusherConnection alloc] init];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client connection:connection failedWithError:nil];
    
    // THEN
    XCTAssertEqual(expectedState, self.pusherMgr.connectionState);
}

- (void)testPusherDisconnected {
    // GIVEN
    PTPusherConnectionState expectedState = PTPusherConnectionDisconnected;
    AMBPTPusherConnection *connection = [[AMBPTPusherConnection alloc] init];
    
    // WHEN
    [self.pusherMgr pusher:self.pusherMgr.client connection:connection didDisconnectWithError:nil willAttemptReconnect:YES];
    
    // THEN
    XCTAssertEqual(expectedState, self.pusherMgr.connectionState);
}

- (void)testReceivedIdentifyAction {
    // GIVEN
    [[[self.mockPusherMgr expect] andDo:nil] closeSocket];
    
    // WHEN
    [self.pusherMgr receivedIdentifyAction];
    
    // THEN
    XCTAssertTrue(self.pusherMgr.campaignListRecieved);
    [self.mockPusherMgr verify];
}

- (void)testCloseSocket {
    // GIVEN
    self.pusherMgr.campaignListRecieved = YES;
    [AmbassadorSDK sharedInstance].identify.identifyProcessComplete = YES;
    
    id mockClient = [OCMockObject mockForClass:[AMBPTPusher class]];
    [[[mockClient expect] andDo:nil] disconnect];
    self.pusherMgr.client = mockClient;
    
    id mockChannel = [OCMockObject mockForClass:[AMBPTPusherPrivateChannel class]];
    [[[mockChannel expect] andDo:nil] unsubscribe];
    self.pusherMgr.channel = mockChannel;
    
    id mockValues = [OCMockObject mockForClass:[AMBValues class]];
    [[[mockValues expect] andDo:nil] setPusherChannelObject:nil];
    
    id mockConversionClass = [OCMockObject mockForClass:[AMBConversion class]];
    [[[mockConversionClass expect] andDo:nil] sendConversions];
    [AmbassadorSDK sharedInstance].conversion = mockConversionClass;
    
    // WHEN
    [self.pusherMgr closeSocket];
    
    // THEN
    [mockClient verify];
    [mockChannel verify];
    [mockValues verify];
    [mockConversionClass verify];
    
    [mockClient stopMocking];
    [mockChannel stopMocking];
    [mockValues stopMocking];
    [mockConversionClass stopMocking];
}

@end
