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
#import "AMBOptions.h"

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

- (void)testValidatedEmails {
    // GIVEN
    AMBContact *mockContactSuccess1 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess2 = [[AMBContact alloc] init];
    AMBContact *mockContactFailure = [[AMBContact alloc] init];
    
    mockContactSuccess1.value = @"test1@test.com";
    mockContactSuccess2.value = @"test2@test.com";
    mockContactFailure.value = @"test.com";
    NSArray *mockContactArray = [[NSArray alloc] initWithObjects:mockContactSuccess1, mockContactSuccess2, mockContactFailure, nil];
    
    // WHEN
    NSMutableArray *validatedArray = [AMBBulkShareHelper validatedEmails:mockContactArray];
    
    // THEN
    XCTAssert(validatedArray.count == 2);
    XCTAssertEqual(mockContactSuccess1.value, validatedArray[0]);
    XCTAssertEqual(mockContactSuccess2.value, validatedArray[1]);
    XCTAssertFalse([validatedArray containsObject:mockContactFailure.value]);
}

- (void)testValidatedPhoneNumbers {
    // GIVEN
    AMBContact *mockContactSuccess1 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess2 = [[AMBContact alloc] init];
    AMBContact *mockContactSuccess3 = [[AMBContact alloc] init];
    AMBContact *mockContactFailure = [[AMBContact alloc] init];
    
    mockContactSuccess1.value = @"(555)555-5555";
    mockContactSuccess2.value = @"1(555)555-5555";
    mockContactSuccess3.value = @"555-5555";
    mockContactFailure.value = @"123-45678";
    NSArray *mockContactArray = [[NSArray alloc] initWithObjects:mockContactSuccess1, mockContactSuccess2, mockContactSuccess3, mockContactFailure, nil];
    
    // WHEN
    NSMutableArray *validatedArray = [AMBBulkShareHelper validatedPhoneNumbers:mockContactArray];
    
    // THEN
    XCTAssert(validatedArray.count == 3);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess1.value] isEqualToString:validatedArray[0]]);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess2.value] isEqualToString:validatedArray[1]]);
    XCTAssert([[AMBBulkShareHelper stripPhoneNumber:mockContactSuccess3.value] isEqualToString:validatedArray[2]]);
    XCTAssertFalse([validatedArray containsObject:[AMBBulkShareHelper stripPhoneNumber:mockContactFailure.value]]);
}

- (void)testEmailValidationBool {
    // GIVEN
    NSString *mockSuccessEmail = @"test@test.com";
    NSString *mockFailureEmail = @"test.com@testcom";
    
    // WHEN
    BOOL test1 = [AMBBulkShareHelper isValidEmail:mockSuccessEmail];
    BOOL test2 = [AMBBulkShareHelper isValidEmail:mockFailureEmail];
    
    // THEN
    XCTAssertTrue(test1);
    XCTAssertFalse(test2);
}

- (void)testPhoneNumberValidationBool {
    // GIVEN
    NSString *mockSuccessPhoneNumber = @"(555)555-5555";
    NSString *mockFailurePhoneNumber = @"(22)234-5555";
    
    // WHEN
    BOOL successTest = [AMBBulkShareHelper isValidPhoneNumber:[AMBBulkShareHelper stripPhoneNumber:mockSuccessPhoneNumber]];
    BOOL failureTest = [AMBBulkShareHelper isValidPhoneNumber:[AMBBulkShareHelper stripPhoneNumber:mockFailurePhoneNumber]];
    
    // THEN
    XCTAssertTrue(successTest);
    XCTAssertFalse(failureTest);
}

- (void)testStripPhoneNumber {
    // GIVEN
    NSString *mockPhoneNumber1 = @"(555)555-5555";
    NSString *mockPhoneNumber2 = @"+1(555)555-5555";
    NSString *expectedNumber1 = @"5555555555";
    NSString *expectedNumber2 = @"15555555555";
    
    // WHEN
    NSString *strippedNumber1 = [AMBBulkShareHelper stripPhoneNumber:mockPhoneNumber1];
    NSString *strippedNumber2 = [AMBBulkShareHelper stripPhoneNumber:mockPhoneNumber2];
    
    // THEN
    XCTAssertTrue([strippedNumber1 isEqualToString:expectedNumber1]);
    XCTAssertTrue([strippedNumber2 isEqualToString:expectedNumber2]);
}

@end
