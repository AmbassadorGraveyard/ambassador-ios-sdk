//
//  AMBConversionsTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBConversion.h"

@interface AMBConversionsTests : XCTestCase

@property (nonatomic, strong) NSString *mockUniversalToken;

@end

@implementation AMBConversionsTests

- (void)setUp {
    [super setUp];
    self.mockUniversalToken = @"***REMOVED***";
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithKey {
    // GIVEN
    AMBConversion *mockConversion;
    
    // WHEN
    mockConversion  = [[AMBConversion alloc] initWithKey:self.mockUniversalToken];
    
    // THEN
    XCTAssertEqualObjects(self.mockUniversalToken, mockConversion.key, @"%@ is not equal to %@", self.mockUniversalToken, mockConversion.key);
    XCTAssertNotNil(mockConversion);
}

- (void)testRegisterConversionSuccess {
    // GIVEN
    XCTestExpectation *completeExpectation = [self expectationWithDescription:@"Registration complete"];
    AMBConversion *mockConversion = [[AMBConversion alloc] initWithKey:self.mockUniversalToken];
    
    AMBConversionParameters *mockParameters = [[AMBConversionParameters alloc] init];
    mockParameters.mbsy_email = @"test@test.com";
    mockParameters.mbsy_campaign = @206;
    mockParameters.mbsy_revenue = @200;
    
    __block NSError *expectedError;
    
    // WHEN
    [mockConversion registerConversionWithParameters:mockParameters completion:^(NSError *error) {
        [completeExpectation fulfill];
        expectedError = error;
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    // THEN
    XCTAssertNil(expectedError);
    XCTAssertNil(mockParameters.isValid);
}

- (void)testRegisterConversionFail {
    // GIVEN
    XCTestExpectation *completedExpectation = [self expectationWithDescription:@"Registation attempt complete"];
    AMBConversion *mockConversion = [[AMBConversion alloc] initWithKey:self.mockUniversalToken];
    
    AMBConversionParameters *mockParameters = [[AMBConversionParameters alloc] init];
    mockParameters.mbsy_email = @"test@test.com";
    mockParameters.mbsy_campaign = @200;
    
    __block NSError *expectedError;
    
    // WHEN
    [mockConversion registerConversionWithParameters:mockParameters completion:^(NSError *error) {
        [completedExpectation fulfill];
        expectedError = error;
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    // THEN
    XCTAssertNotNil(expectedError);
    XCTAssertNotNil(mockParameters.isValid);
}

- (void)testSendConversions {
    // GIVEN
    
    // WHEN
    
    // THEN
}

@end
