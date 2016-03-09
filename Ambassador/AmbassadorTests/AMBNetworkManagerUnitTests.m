//
//  AMBNetworkManagerUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBNetworkManager.h"
#import "AMBConversionParameters.h"
#import "AMBConversionParameter_Internal.h"

@interface AMBNetworkManagerUnitTests : XCTestCase

@property (nonatomic, strong) AMBNetworkManager * networkManager;
@property (nonatomic) id mockURLSession;
@property (nonatomic) id mockResponse;

@end


@implementation AMBNetworkManagerUnitTests

- (void)setUp {
    [super setUp];
    if (!self.networkManager) {
        self.networkManager = [AMBNetworkManager sharedInstance];
    }
    
    self.mockURLSession = [OCMockObject partialMockForObject:self.networkManager.urlSession];
    self.mockResponse = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[self.mockResponse expect] andReturnValue:OCMOCK_VALUE((NSInteger)200)] statusCode];
    self.networkManager.urlSession = self.mockURLSession;
}

- (void)tearDown {
    [self.mockResponse stopMocking];
    [self.mockURLSession stopMocking];
    [super tearDown];
}


#pragma mark - SharedInstance Test

- (void)testSharedInstance {
    XCTAssertNotNil(self.networkManager);
}


#pragma mark - Network Call Tests

- (void)testSendIdentifyCall {
    // GIVEN
    NSString *expectedString = @"Response String";
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"sendIdentifyCompletion"];
    [self setUpURLCompletionWithData:[expectedString dataUsingEncoding:NSUTF8StringEncoding] response:self.mockResponse error:nil];
    
    // WHEN
    __block NSString *returnString;
    [self.networkManager sendIdentifyForCampaign:@"123456" shouldEnroll:YES success:^(NSString *response) {
        returnString = response;
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
        XCTAssertEqualObjects(expectedString, returnString);
    }];
}

- (void)testSendShareTrackCall {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"shareTrackCompletion"];
    AMBSocialServiceType facebookTrack = AMBSocialServiceTypeFacebook;
    NSMutableArray *mockArray = [NSMutableArray arrayWithObject:@"test"];
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:mockArray options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    __block NSDictionary *returnValue;
    [self.networkManager sendShareTrackForServiceType:facebookTrack contactList:mockArray success:^(NSDictionary *response) {
        returnValue = response;
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        XCTAssertEqual([returnValue count], 1);
        [self.mockURLSession verify];
    }];
}

- (void)testBulkShareSMS {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"bulkShareSMSCompletion"];
    NSString *mockMessage = @"test message";
    NSArray *mockPhoneNums = @[@"555-555-5555", @"123-456-7890"];
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:mockPhoneNums options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    __block NSDictionary *returnValue;
    [self.networkManager bulkShareSmsWithMessage:mockMessage phoneNumbers:mockPhoneNums success:^(NSDictionary *response) {
        returnValue = response;
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        XCTAssertEqual([returnValue count], 2);
        [self.mockURLSession verify];
    }];
}

- (void)testBulkShareEmail {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"bulkShareEmailCompletion"];
    NSString *mockMessage = @"test message";
    NSArray *mockEmails = @[@"test@example.com", @"test2@example.com", @"test3@example.com"];
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:mockEmails options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    __block NSDictionary *returnValue;
    [self.networkManager bulkShareEmailWithMessage:mockMessage emailAddresses:mockEmails success:^(NSDictionary *response) {
        returnValue = response;
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        XCTAssertEqual([returnValue count], 3);
        [self.mockURLSession verify];
    }];
}

- (void)testUpdateName {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"updateNamesCompletion"];
    NSString *mockFirstName = @"Test";
    NSString *mockLastName = @"McTesty";
    NSString *mockFullName = [NSString stringWithFormat:@"%@ %@", mockFirstName, mockLastName];
    [self setUpURLCompletionWithData:[mockFullName dataUsingEncoding:NSUTF8StringEncoding] response:self.mockResponse error:nil];
    
    // WHEN
    [self.networkManager updateNameWithFirstName:mockFirstName lastName:mockLastName success:^(NSDictionary *response) {
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
    }];
}

- (void)testSendConversion {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"sendConversionCompletion"];
    AMBConversionParameters *mockParams = [[AMBConversionParameters alloc] init];
    mockParams.mbsy_email = @"test@exampl.com";
    mockParams.mbsy_revenue = @1;
    mockParams.mbsy_campaign = @0;
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:[mockParams propertyDictionary] options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    [self.networkManager sendRegisteredConversion:[mockParams propertyDictionary] success:^(NSDictionary *response) {
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
    }];
}

- (void)testGetPusherSessionCall {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"getPusherSessionCompletion"];
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:@{@"test" : @"testValue" } options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    [self.networkManager getPusherSessionWithSuccess:^(NSDictionary *response) {
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
    }];
}

- (void)testGetLargePusherPayload {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"getLargePusherPayloadCompletion"];
    NSString *mockURL = @"http://test.example.com";
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:@{@"test" : @"testValue"} options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    [self.networkManager getLargePusherPayloadFromUrl:mockURL success:^(NSDictionary *response) {
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
    }];
}

- (void)testUpdateAPNDeviceToken {
    // GIVEN
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"updateAPN"];
    NSString *deviceToken = @"6sd4f6df79ev1re7rt";
    [self setUpURLCompletionWithData:[NSJSONSerialization dataWithJSONObject:@{@"test" : @"testValue"} options:0 error:nil] response:self.mockResponse error:nil];
    
    // WHEN
    [self.networkManager updateAPNDeviceToken:deviceToken success:^(NSDictionary *response) {
        [successExpectation fulfill];
    } failure:nil];
    
    // THEN
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError * _Nullable error) {
        [self.mockURLSession verify];
    }];
}


#pragma mark - Helper Functions

- (void)setUpURLCompletionWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    [[[self.mockURLSession expect] andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) = nil;
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(data, response, error);
    }] dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg invokeBlock]];
}

@end
