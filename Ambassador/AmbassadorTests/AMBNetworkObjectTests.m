//
//  AMBNetworObjectTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBNetworkManager.h"
#import "AMBNetworkObject.h"
#import "AMBTests.h"
#import "AMBValues.h"

@interface AMBNetworkObjectTests : AMBTests

@end


@implementation AMBNetworkObjectTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


#pragma mark - NetworkObject Tests

- (void)testToDictionary {
    // GIVEN
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] init];
    identifyObject.email = @"test@example.com";
    identifyObject.campaign_id = @"1";
    
    // WHEN
    NSMutableDictionary *expectedDictionary = [identifyObject toDictionary];
    
    // THEN
    XCTAssertEqual(4, expectedDictionary.count);
    XCTAssertEqualObjects(identifyObject.email, expectedDictionary[@"email"]);
    XCTAssertEqualObjects(identifyObject.campaign_id, expectedDictionary[@"campaign_id"]);
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

- (void)testToData {
    // GIVEN
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] init];
    
    // WHEN
    NSData *data = [identifyObject toData];
    
    // THEN
    XCTAssertNotNil(data);
}


#pragma mark - Pusher Auth Tests

- (void)testInit {
    // GIVEN
    NSString *blankString = @"";
    
    // WHEN
    AMBPusherAuthNetworkObject *pusherAuth = [[AMBPusherAuthNetworkObject alloc] init];
    
    // THEN
    XCTAssertEqualObjects(pusherAuth.auth_type, blankString);
    XCTAssertEqualObjects(pusherAuth.channel, blankString);
    XCTAssertEqualObjects(pusherAuth.socket_id, blankString);
}


#pragma mark - URL Object Tests

- (void)testInitWithDictionary {
    // GIVEN
    NSDictionary *mockDict = @{ @"campaign_uid" : @"1", @"short_code" : @"test", @"subject" : @"test subject", @"url" : @"fake.url/test" };
    
    // WHEN
    AMBUserUrlNetworkObject *object = [[AMBUserUrlNetworkObject alloc] initWithDictionary:mockDict];
    
    // THEN
    XCTAssertEqualObjects(mockDict[@"campaign_uid"], object.campaign_uid);
    XCTAssertEqualObjects(mockDict[@"short_code"], object.short_code);
    XCTAssertEqualObjects(mockDict[@"subject"], object.subject);
    XCTAssertEqualObjects(mockDict[@"url"], object.url);
}


#pragma mark - User Object tests

- (void)testFillWithURL {
    // GIVEN
    AMBUserNetworkObject *userNetworkObject = [[AMBUserNetworkObject alloc] init];
    id mockNetworkObject = [OCMockObject partialMockForObject:userNetworkObject];
    [[mockNetworkObject expect] fillWithDictionary:[OCMArg any]];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)(NSDictionary *response) = nil;
        [invocation getArgument:&success atIndex:3];
        success(nil);
    }] getLargePusherPayloadFromUrl:[OCMArg any] success:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    // WHEN
    [userNetworkObject fillWithUrl:@"fakeurl" completion:^(NSString *error) {
        nil;
    }];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkObject verify];
}


#pragma mark - Identify Objects Tests

- (void)testIdentifyInit {
    // GIVEN
    NSString *blankString = @"";
    
    // WHEN
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] init];
    
    // THEN
    XCTAssertEqualObjects(identifyObject.email, blankString);
    XCTAssertEqualObjects(identifyObject.campaign_id, blankString);
    XCTAssertEqualObjects(identifyObject.source, blankString);
    XCTAssertFalse(identifyObject.enroll);
}


#pragma mark - Share Track Object Tests

- (void)testShareTrackInit {
    // GIVEN
    NSString *blankString = @"";
    [AMBValues setUserEmail:@"testuser@example.com"];
    
    // WHEN
    AMBShareTrackNetworkObject *trackObject = [[AMBShareTrackNetworkObject alloc] init];
    
    // THEN
    XCTAssertEqualObjects(trackObject.recipient_username, blankString);
    XCTAssertEqualObjects(trackObject.recipient_email, blankString);
    XCTAssertEqualObjects(trackObject.short_code, blankString);
    XCTAssertEqualObjects(trackObject.social_name, blankString);
    XCTAssertEqualObjects(trackObject.from_email, [AMBValues getUserEmail]);
}


#pragma mark - Bulk Share Email Tests

- (void)testInitWithEmails {
    // GIVEN
    NSArray *emails = @[@"test@example.com", @"test2@example.com", @"test3@example.com"];
    NSString *message = @"This is a test message";
    
    // WHEN
    AMBBulkShareEmailObject *emailObject = [[AMBBulkShareEmailObject alloc] initWithEmails:emails message:message];
    
    // THEN
    XCTAssertEqual([emailObject.to_emails count], [emails count]);
    XCTAssertEqualObjects(emailObject.message, message);
}


#pragma mark - Bulk Share SMS Tests

- (void)testInitWithPhoneNumbers {
    // GIVEN
    NSArray *numbers = @[@"555-555-5555", @"123-456-7891", @"555-455-5654"];
    NSString *senderName = @"Test McTest";
    NSString *message = @"Another test message";
    
    // WHEN
    AMBBulkShareSMSObject *smsObject = [[AMBBulkShareSMSObject alloc] initWithPhoneNumbers:numbers fromSender:senderName message:message];
    
    // THEN
    XCTAssertEqualObjects(smsObject.name, senderName);
    XCTAssertEqualObjects(smsObject.message, message);
    XCTAssertEqual([smsObject.to count], [numbers count]);
}


#pragma mark - Update Name Tests

- (void)testInitWithFirstName {
    // GIVEN
    NSString *firstName = @"Test";
    NSString *lastName = @"McTest";
    NSString *email = @"test@example.com";
    
    // WHEN
    AMBUpdateNameObject *updateNameObject = [[AMBUpdateNameObject alloc] initWithFirstName:firstName lastName:lastName email:email];
    
    // THEN
    XCTAssertEqualObjects(updateNameObject.update_data[@"first_name"], firstName);
    XCTAssertEqualObjects(updateNameObject.update_data[@"last_name"], lastName);
    XCTAssertEqualObjects(updateNameObject.email, email);
}


#pragma mark - Update APNToken Tests

- (void)testInitWithAPNToken {
    // GIVEN
    NSString *apnDeviceToken = @"54dsf65s433c24x35cva8s984";
    NSString *email = @"test@example.com";
    [AMBValues setUserEmail:email];
    
    // WHEN
    AMBUpdateAPNTokenObject *updateAPNTokenObject = [[AMBUpdateAPNTokenObject alloc] initWithAPNDeviceToken:apnDeviceToken];
    
    // THEN
    XCTAssertEqualObjects(updateAPNTokenObject.update_data[@"apnToken"], apnDeviceToken);
    XCTAssertEqualObjects(updateAPNTokenObject.email, email);
}

@end
