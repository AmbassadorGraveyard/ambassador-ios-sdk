//
//  AMBWelcomeScreenParametersTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBWelcomeScreenParameters.h"

@interface AMBWelcomeScreenParametersTests : XCTestCase

@end

@implementation AMBWelcomeScreenParametersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    // GIVEN
    NSString *expectedReferralMessage = @"You have been referred to this company";
    NSString *expectedDetailMessage = @"Welcome to our app!";
    NSArray *expectedArray = @[];
    NSString *expectedActionButtonTitle = @"";
    UIColor *expectedAccentColor = [UIColor redColor];
    
    // WHEN
    AMBWelcomeScreenParameters *params = [[AMBWelcomeScreenParameters alloc] init];
    
    // THEN
    XCTAssertEqualObjects(params.referralMessage, expectedReferralMessage);
    XCTAssertEqualObjects(params.detailMessage, expectedDetailMessage);
    XCTAssertEqualObjects(params.linkArray, expectedArray);
    XCTAssertEqualObjects(params.actionButtonTitle, expectedActionButtonTitle);
    XCTAssertEqualObjects(params.accentColor, expectedAccentColor);
}

@end
