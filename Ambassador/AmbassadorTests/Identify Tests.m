//
//  Identify Tests.m
//  Ambassador
//
//  Created by Diplomat on 8/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Identify.h"

@interface Identify_Tests : XCTestCase
@property NSString *uid;
@property Identify *identify;
@end

@implementation Identify_Tests

- (void)setUp {
    [super setUp];
    self.identify = [[Identify alloc] init];
    self.uid = @"";
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInsightsNoUID {
    
    XCTestExpectation *exp = [self expectationWithDescription:@"Testing getInsights no UID"];
    
    self.uid = @"";
    [self.identify getInsightsDataForUID:self.uid success:^(NSMutableDictionary *response) {
        XCTAssertNotNil(response);
        NSLog(@"%@", response);
        [exp fulfill];
    } fail:^(NSError *error) {
        XCTFail(@"getInsights no UID failed: %@", error);
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testInsightsFullUID {
    
    XCTestExpectation *exp = [self expectationWithDescription:@"Testing getInsights no UID"];
    
    self.uid = @"7562a06d1d334b5940f657ddaad790a66788a96f2576b2d61296fd31";
    [self.identify getInsightsDataForUID:self.uid success:^(NSMutableDictionary *response) {
        XCTAssertNotNil(response);
        NSLog(@"%@", response);
        [exp fulfill];
    } fail:^(NSError *error) {
        XCTFail(@"getInsights no UID failed: %@", error);
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testInsightsFullUIDandNil {
    
    self.uid = @"7562a06d1d334b5940f657ddaad790a66788a96f2576b2d61296fd31";
    [self.identify getInsightsDataForUID:self.uid success:nil fail:nil];
    
    for (int i = 0; i < 1000000000; ++i)
    {}
    NSLog(@"DONE!");
}


@end
