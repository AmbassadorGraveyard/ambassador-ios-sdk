//
//  AMBPusherChannelObjectTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBPusherChannelObject.h"

@interface AMBPusherChannelObjectTests : XCTestCase

@property (nonatomic, strong) AMBPusherChannelObject * pusherChannelObj;

@end

@implementation AMBPusherChannelObjectTests

- (void)setUp {
    [super setUp];
    self.pusherChannelObj = [[AMBPusherChannelObject alloc] init];
    self.pusherChannelObj.channelName = @"private-snippet-channel@user=privatetestchannel";
    self.pusherChannelObj.sessionId = @"privatetestchannel";
    self.pusherChannelObj.expiresAt = [NSDate dateWithTimeIntervalSinceNow:10000];
    self.pusherChannelObj.requestId = @456789.100;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCreateObjectFromDictionary {
    // GIVEN
    NSString *mockChannelName = @"private-snippet-channel@user=privatetestchannel";
    NSString *mockSessionID = @"privatetestchannel";
    NSString *mockExpiresAtDateString = @"2015-11-18T15:11:25.439";
    
    NSDateFormatter *mockDateFormatter = [[NSDateFormatter alloc] init];
    [mockDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    NSDate *mockExpriresAtDate = [mockDateFormatter dateFromString:mockExpiresAtDateString];
    
    NSMutableDictionary *mockDictionary = [[NSMutableDictionary alloc] init];
    [mockDictionary setValue:mockChannelName forKey:@"channel_name"];
    [mockDictionary setValue:mockSessionID forKey:@"client_session_uid"];
    [mockDictionary setValue:mockExpiresAtDateString forKey:@"expires_at"];
    
    AMBPusherChannelObject *expectedObject = [[AMBPusherChannelObject alloc] init];
    
    // WHEN
    [expectedObject createObjectFromDictionary:mockDictionary];
    
    // THEN
    XCTAssertEqualObjects(mockChannelName, expectedObject.channelName, @"%@ is not equal to %@", mockChannelName, expectedObject.channelName);
    XCTAssertEqualObjects(mockSessionID, expectedObject.sessionId, @"%@ is not equal to %@", mockSessionID, expectedObject.sessionId);
    XCTAssertEqualObjects(mockExpriresAtDate, expectedObject.expiresAt, @"%@ is not equal to %@", mockExpriresAtDate, expectedObject.expiresAt);
}

- (void)testDateIsExpired {
    // GIVEN
    AMBPusherChannelObject *mockUnexpiredObject = [[AMBPusherChannelObject alloc] init];
    mockUnexpiredObject.expiresAt = [NSDate dateWithTimeIntervalSinceNow:10]; // Sets a date that will not be expired
    
    AMBPusherChannelObject *mockExpiredObject = [[AMBPusherChannelObject alloc] init];
    NSString *mockExpiresAtDateString = @"2014-11-18T15:11:25.439";
    NSDateFormatter *mockDateFormatter = [[NSDateFormatter alloc] init];
    [mockDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz"];
    mockExpiredObject.expiresAt = [mockDateFormatter dateFromString:mockExpiresAtDateString]; // Sets a date that should always be expired
    
    BOOL notExpired;
    BOOL expired;
    
    // WHEN
    notExpired = mockUnexpiredObject.isExpired;
    expired = mockExpiredObject.isExpired;
    
    // THEN
    XCTAssertFalse(notExpired);
    XCTAssertTrue(expired);
}

@end