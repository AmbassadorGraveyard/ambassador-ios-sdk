//
//  AMBAmbassadorNetworkManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBAmbassadorNetworkManager.h"
#import "AMBNetworkObject.h"
#import "AMBTests.h"
#import "AMBMockObjects.h"
#import "AMBOptions.h"
#import "AmbassadorSDK_Internal.h"

@interface AMBAmbassadorNetworkManagerTests : AMBTests

@property (nonatomic, strong) AMBAmbassadorNetworkManager * networkManager;

@end


@implementation AMBAmbassadorNetworkManagerTests
- (void)setUp {
    [super setUp];
    self.networkManager = [AMBAmbassadorNetworkManager sharedInstance];
    self.devToken = [NSString stringWithFormat:@"SDKToken %@",self.devToken];
    self.prodToken = [NSString stringWithFormat:@"SDKToken %@",self.prodToken];
    [AmbassadorSDK sharedInstance].universalToken = self.devToken;
    [AmbassadorSDK sharedInstance].universalID = self.devID;}

- (void)tearDown {
    [super tearDown];
}

- (void)testSendNetworkObject {
    // GIVEN
    XCTestExpectation *shareTrackExpectation = [self expectationWithDescription:@"Share track completion handler called"];
    __block NSError *expectedError;
    __block NSInteger statusCode;
    
    // WHEN
    [self.networkManager sendNetworkObject:[AMBMockShareTrackObject validEmailShare] url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [shareTrackExpectation fulfill];
        expectedError = error;
        statusCode = ((NSHTTPURLResponse*)response).statusCode;
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    
    // THEN
    XCTAssertNil(expectedError, @"There was an error - %@", expectedError);
    XCTAssertGreaterThanOrEqual(statusCode, 200);
    XCTAssertLessThanOrEqual(statusCode, 299);
}

- (void)testGetPusherChannelName {
    // GIVEN
    XCTestExpectation *getPusherExpectation = [self expectationWithDescription:@"Get Pusher name completion handler called"];
    __block NSError *expectedError;
    __block NSString *returnString;
    
    // WHEN
    [self.networkManager pusherChannelNameUniversalToken:self.devToken universalID:self.devID completion:^(NSString *string, NSMutableDictionary *dict, NSError *error) {
        [getPusherExpectation fulfill];
        expectedError = error;
        returnString = string;
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    
    // THEN
    XCTAssertNil(expectedError, @"There was an error - %@", expectedError);
    XCTAssertTrue([returnString containsString:@"private-channel"], @"%@ did not contain private-snippet-channel", returnString);
}

- (void)testPusherAuthUrl {
    // GIVEN
    NSString *mockPusherAuthString = @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";
    NSString *expectedPusherAuthString;
    
    // WHEN
    expectedPusherAuthString = [AMBAmbassadorNetworkManager pusherAuthSubscribeUrl];
    
    // THEN
    XCTAssertEqualObjects(mockPusherAuthString, expectedPusherAuthString, @"%@ is not equal to %@", mockPusherAuthString, expectedPusherAuthString);
}


- (void)testPusherSessionUrl {
    // GIVEN
    NSString *mockPusherSessionString = @"https://dev-ambassador-api.herokuapp.com/auth/session/";
    NSString *expectedPusherSessionString;
    
    // WHEN
    expectedPusherSessionString = [AMBAmbassadorNetworkManager pusherSessionSubscribeUrl];
    
    // THEN
    XCTAssertEqualObjects(mockPusherSessionString, expectedPusherSessionString, @"%@ is not equal to %@", mockPusherSessionString, expectedPusherSessionString);
}

- (void)testSendIdentifyUrl {
    // GIVEN
    NSString *mockSendIdentifyString = @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/";
    NSString *expectedSendIdentifyString;
    
    // WHEN
    expectedSendIdentifyString = [AMBAmbassadorNetworkManager sendIdentifyUrl];
    
    // THEN
    XCTAssertEqualObjects(mockSendIdentifyString, expectedSendIdentifyString, @"%@ is not equal to %@", mockSendIdentifyString, expectedSendIdentifyString);
}

- (void)testSendShareTrackUrl {
    // GIVEN
    NSString *mockSendTrackUrl = @"https://dev-ambassador-api.herokuapp.com/track/share/";
    NSString *expectedSendTrackUrl;
    
    // WHEN
    expectedSendTrackUrl = [AMBAmbassadorNetworkManager sendShareTrackUrl];
    
    // THEN
    XCTAssertEqualObjects(mockSendTrackUrl, expectedSendTrackUrl, @"%@ is not equal to %@", mockSendTrackUrl, expectedSendTrackUrl);
}

- (void)testBulkShareEmailUrl {
    // GIVEN
    NSString *mockBulkShareEmailUrl = @"https://dev-ambassador-api.herokuapp.com/share/email/";
    NSString *expectedBulkShareEmailUrl;
    
    // WHEN
    expectedBulkShareEmailUrl = [AMBAmbassadorNetworkManager bulkShareEmailUrl];
    
    // THEN
    XCTAssertEqualObjects(mockBulkShareEmailUrl, expectedBulkShareEmailUrl, @"%@ is not equal to %@", mockBulkShareEmailUrl, expectedBulkShareEmailUrl);
}

- (void)testBulkdShareSMSUrl {
    // GIVEN
    NSString *mockBulkShareSMSUrl = @"https://dev-ambassador-api.herokuapp.com/share/sms/";
    NSString *expectedBulkShareSMSUrl;
    
    // WHEN
    expectedBulkShareSMSUrl = [AMBAmbassadorNetworkManager bulkShareSMSUrl];
    
    // THEN
    XCTAssertEqualObjects(mockBulkShareSMSUrl, expectedBulkShareSMSUrl, @"%@ is not equal to %@", mockBulkShareSMSUrl, expectedBulkShareSMSUrl);
}


@end
