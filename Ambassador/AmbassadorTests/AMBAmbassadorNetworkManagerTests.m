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
    XCTAssertTrue([returnString containsString:@"private-snippet-channel"], @"%@ did not contain private-snippet-channel", returnString);
}



@end
