//
//  AMBBulkShareHelperUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/5/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBContact.h"
#import "AMBBulkShareHelper.h"

@interface AMBBulkShareHelperUnitTests : XCTestCase

@end

@implementation AMBBulkShareHelperUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

- (void)testValidatedEmails {
    // ARRANGE
    AMBContact *mockContactSuccess1 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess2 = [[AMBContact alloc] init];
    AMBContact *mockContactFailure = [[AMBContact alloc] init];
    
    mockContactSuccess1.value = @"test1@test.com";
    mockContactSuccess2.value = @"test2@test.com";
    mockContactFailure.value = @"test.com";
    NSArray *mockContactArray = [[NSArray alloc] initWithObjects:mockContactSuccess1, mockContactSuccess2, mockContactFailure, nil];
    
    // ACT
    NSMutableArray *validatedArray = [AMBBulkShareHelper validatedEmails:mockContactArray];
    
    // ASSERT
    XCTAssert(validatedArray.count == 2);
    XCTAssertEqual(mockContactSuccess1.value, validatedArray[0]);
    XCTAssertEqual(mockContactSuccess2.value, validatedArray[1]);
    XCTAssertFalse([validatedArray containsObject:mockContactFailure.value]);
}

- (void)testValidatedPhoneNumbers {
    // ARRANGE
    AMBContact *mockContactSuccess1 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess2 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess3 = [[AMBContact alloc] init];
    AMBContact *mockContactFailure = [[AMBContact alloc] init];
    
    mockContactSuccess1.value = @"(555)555-5555";
    mockContactSuccess2.value = @"1(555)555-5555";
    mockContactSuccess3.value = @"555-5555";
    mockContactFailure.value = @"123-45678";
    NSArray *mockContactArray = [[NSArray alloc] initWithObjects:mockContactSuccess1, mockContactSuccess2, mockContactSuccess3, mockContactFailure, nil];
    
    // ACT
    NSMutableArray *validatedArray = [AMBBulkShareHelper validatedPhoneNumbers:mockContactArray];
    
    // ASSERT
    XCTAssert(validatedArray.count == 3);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess1.value] isEqualToString:validatedArray[0]]);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess2.value] isEqualToString:validatedArray[1]]);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess3.value] isEqualToString:validatedArray[2]]);
    XCTAssertFalse([validatedArray containsObject:[AMBBulkShareHelper stripPhoneNumber:mockContactFailure.value]]);
}



@end
