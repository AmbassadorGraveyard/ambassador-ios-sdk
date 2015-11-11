//
//  AMBNetworObjectTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBNetworkObject.h"
#import "AMBMockObjects.h"
#import "AMBTests.h"

@interface AMBNetworObjectTests : AMBTests

@end

@implementation AMBNetworObjectTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testToDictionary {
    // GIVEN
    NSString *mockShortCode = @"lbBf";
    NSString *mockMessage = @"Test message";
    NSString *mockSubjectLine = @"Test subject line.";
    NSArray *mockEmails = [[NSArray alloc] initWithObjects:@"test@test.com", @"test2@test.com", @"test3@gmail.com", nil];
    AMBBulkShareEmailObject *mockShareEmailObj = [[AMBBulkShareEmailObject alloc] initWithEmails:mockEmails shortCode:mockShortCode message:mockMessage subjectLine:mockSubjectLine];
    
    // WHEN
    NSMutableDictionary *expectedDictionary = [mockShareEmailObj toDictionary];
    
    // THEN
    XCTAssertEqual(4, expectedDictionary.count, @"Expect count was actually %i, not 4", (int)expectedDictionary.count);
    XCTAssertEqualObjects(mockShortCode, expectedDictionary[@"short_code"], @"%@ is not equal to %@", mockShortCode, expectedDictionary[@"short_code"]);
    XCTAssertEqualObjects(mockMessage, expectedDictionary[@"message"], @"%@ is not equal to %@", mockMessage, expectedDictionary[@"message"]);
    XCTAssertEqualObjects(mockSubjectLine, expectedDictionary[@"subject_line"], @"%@ is not equal to %@", mockSubjectLine, expectedDictionary[@"subject_line"]);
    XCTAssertEqualObjects(mockEmails, expectedDictionary[@"to_emails"], @"%@ is not equal to %@", mockEmails, expectedDictionary[@"to_emails"]);
}

@end
