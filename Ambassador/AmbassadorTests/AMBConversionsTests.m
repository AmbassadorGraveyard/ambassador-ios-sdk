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

@end

@implementation AMBConversionsTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithKey {
    // GIVEN
    NSString *mockUniversalToken = @"abdkeivnslldc992";
    
    // WHEN
     AMBConversion *mockConversion = [[AMBConversion alloc] initWithKey:mockUniversalToken];
    
    // THEN
    XCTAssertEqualObjects(mockUniversalToken, mockConversion.key, @"%@ is not equal to %@", mockUniversalToken, mockConversion.key);
}

- (void)testRegisterConversion {
    // GIVEN
    
    // WHEN
    
    // THEN
}

- (void)testSendConversions {
    // GIVEN
    
    // WHEN
    
    // THEN
}

@end
