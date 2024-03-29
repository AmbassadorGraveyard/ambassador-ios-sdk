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

@end

@implementation AMBPusherChannelObjectTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithDictionary {
    // GIVEN
    NSString *channelName = @"fakeChannelName";
    NSString *dateString = @"2015-11-18T15:11:25.439";
    NSString *clientSessionId = @"fakeClientSessionId";
    NSDictionary *fakeDict = @{ @"channel_name" : channelName, @"expires_at" : dateString, @"client_session_uid" : clientSessionId };
    
    // WHEN
    AMBPusherChannelObject *object = [[AMBPusherChannelObject alloc] initWithDictionary:(NSMutableDictionary*)fakeDict];
    
    // THEN
    XCTAssertEqualObjects(channelName, object.channelName);
    XCTAssertEqualObjects(clientSessionId, object.sessionId);
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
