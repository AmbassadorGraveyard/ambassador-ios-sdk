//
//  AMBConversionParametersTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBConversionParameters.h"

@interface AMBConversionParametersTests : XCTestCase

@end

@implementation AMBConversionParametersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
//
//- (void)testIsValid {
//    // GIVEN
//    AMBConversionParameters *mockValidParameters = [[AMBConversionParameters alloc] init];
//    mockValidParameters.mbsy_email = @"jduntest@test.com";
//    mockValidParameters.mbsy_campaign = @206;
//    mockValidParameters.mbsy_revenue = @200;
//    
//    AMBConversionParameters *mockInvalidParameters = [[AMBConversionParameters alloc] init];
//    mockInvalidParameters.mbsy_revenue = @200;
//    mockInvalidParameters.mbsy_campaign = @206;
//    
//    // WHEN
//    NSError *expectedNilError = mockValidParameters.isValid;
//    NSError *expectedError = mockInvalidParameters.isValid;
//    
//    // THEN
//    XCTAssertNil(expectedNilError);
//    XCTAssertNotNil(expectedError);
//}

@end
