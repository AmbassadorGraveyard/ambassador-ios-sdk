//
//  AMBNetworObjectTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBNetworkObject.h"
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
    XCTAssertEqual(5, expectedDictionary.count, @"Expected count was actually %i, not 5", (int)expectedDictionary.count);
    XCTAssertEqualObjects(mockShortCode, expectedDictionary[@"short_code"], @"%@ is not equal to %@", mockShortCode, expectedDictionary[@"short_code"]);
    XCTAssertEqualObjects(mockMessage, expectedDictionary[@"message"], @"%@ is not equal to %@", mockMessage, expectedDictionary[@"message"]);
    XCTAssertEqualObjects(mockSubjectLine, expectedDictionary[@"subject_line"], @"%@ is not equal to %@", mockSubjectLine, expectedDictionary[@"subject_line"]);
    XCTAssertEqualObjects(mockEmails, expectedDictionary[@"to_emails"], @"%@ is not equal to %@", mockEmails, expectedDictionary[@"to_emails"]);
}

- (void)testFillWithDictionary {
    // GIVEN
    NSString *mockCampaign = @"206";
    NSString *mockShortCode = @"lbBf";
    NSString *mockSubject = @"Fake subject line";
    NSString *mockUrl = @"http://mock.url.fake.com";
    BOOL mockActive = YES;
    BOOL mockAccess = YES;
    
    NSMutableDictionary *mockDictionary = [[NSMutableDictionary alloc] init];
    [mockDictionary setValue:mockCampaign forKey:@"campaign_uid"];
    [mockDictionary setValue:mockShortCode forKey:@"short_code"];
    [mockDictionary setValue:mockSubject forKey:@"subject"];
    [mockDictionary setValue:mockUrl forKey:@"url"];
    [mockDictionary setValue:[NSNumber numberWithBool:mockAccess] forKey:@"has_access"];
    [mockDictionary setValue:[NSNumber numberWithBool:mockActive] forKey:@"is_active"];
    
    AMBUserUrlNetworkObject *expectedUserUrlNetworkObj = [[AMBUserUrlNetworkObject alloc] init];
   
    // WHEN
    [expectedUserUrlNetworkObj fillWithDictionary:mockDictionary];
    
    // THEN
    XCTAssertEqualObjects(mockCampaign, expectedUserUrlNetworkObj.campaign_uid, @"%@ is not equal to %@", mockCampaign, expectedUserUrlNetworkObj.campaign_uid);
    XCTAssertEqualObjects(mockShortCode, expectedUserUrlNetworkObj.short_code, @"%@ is not equal to %@", mockShortCode, expectedUserUrlNetworkObj.short_code);
    XCTAssertEqualObjects(mockSubject, expectedUserUrlNetworkObj.subject, @"%@ is not equal to %@", mockSubject, expectedUserUrlNetworkObj.subject);
    XCTAssertEqualObjects(mockUrl, expectedUserUrlNetworkObj.url, @"%@ is not equal to %@", mockUrl, expectedUserUrlNetworkObj);
    XCTAssertEqualObjects([NSNumber numberWithBool:mockActive], [NSNumber numberWithBool:expectedUserUrlNetworkObj.is_active], @"%@ is not equal to %@", [NSNumber numberWithBool:mockActive], [NSNumber numberWithBool:expectedUserUrlNetworkObj.is_active]);
    XCTAssertEqualObjects([NSNumber numberWithBool:mockAccess], [NSNumber numberWithBool:expectedUserUrlNetworkObj.has_access], @"%@ is not equal to %@", [NSNumber numberWithBool:mockAccess], [NSNumber numberWithBool:expectedUserUrlNetworkObj.has_access]);
}

@end
