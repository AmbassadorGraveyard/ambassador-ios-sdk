//
//  AMBOptionsTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/12/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBOptions.h"

@interface AMBOptionsTests : XCTestCase

@end

@implementation AMBOptionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStringValueForServiceType {
    // GIVEN
    NSString *mockTwitterString = @"twitter";
    NSString *mockLinkedInString = @"linkedin";
    NSString *mockFacebookString = @"facebook";
    NSString *mockEmailString = @"email";
    NSString *mockSMSString = @"sms";
    
    // WHEN
    NSString *expectedTwitterString = [AMBOptions serviceTypeStringValue:AMBSocialServiceTypeTwitter];
    NSString *expectedLinkedInString = [AMBOptions serviceTypeStringValue:AMBSocialServiceTypeLinkedIn];
    NSString *expectedFacebookString = [AMBOptions serviceTypeStringValue:AMBSocialServiceTypeFacebook];
    NSString *expectedEmailString = [AMBOptions serviceTypeStringValue:AMBSocialServiceTypeEmail];
    NSString *expectedSMSString = [AMBOptions serviceTypeStringValue:AMBSocialServiceTypeSMS];
    NSString *expectedNilString = [AMBOptions serviceTypeStringValue:7];
    
    // THEN
    XCTAssertEqualObjects(mockTwitterString, expectedTwitterString, @"%@ is not equal to %@", mockTwitterString, expectedTwitterString);
    XCTAssertEqualObjects(mockLinkedInString, expectedLinkedInString, @"%@ is not equal to %@", mockLinkedInString, expectedLinkedInString);
    XCTAssertEqualObjects(mockFacebookString, expectedFacebookString, @"%@ is not equal to %@", mockFacebookString, expectedFacebookString);
    XCTAssertEqualObjects(mockEmailString, expectedEmailString, @"%@ is not equal to %@", mockEmailString, expectedEmailString);
    XCTAssertEqualObjects(mockSMSString, expectedSMSString, @"%@ is not equal to %@", mockSMSString, expectedSMSString);
    XCTAssertNil(expectedNilString);
}

@end
