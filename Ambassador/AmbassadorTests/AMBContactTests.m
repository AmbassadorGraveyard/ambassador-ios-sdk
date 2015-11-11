//
//  AMBContactTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBContact.h"

@interface AMBContactTests : XCTestCase

@end

@implementation AMBContactTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullName {
    // GIVEN
    NSString *mockFullName = @"Test McTesty";
    AMBContact *mockContact = [[AMBContact alloc] init];
    mockContact.firstName = @"Test";
    mockContact.lastName = @"McTesty";
    
    // WHEN
    NSString *expectedFullName = [mockContact fullName];
    
    // THEN
    XCTAssertEqualObjects(mockFullName, expectedFullName, @"%@ is not equal to %@", mockFullName, expectedFullName);
}

@end
