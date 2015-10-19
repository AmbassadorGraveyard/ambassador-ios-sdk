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

- (void)testFillWithDictionary {
    AMBMockUserObjects *mockUser = [[AMBMockUserObjects alloc] init];
    NSMutableDictionary *mockUserDictionary = [mockUser mockUser];
    AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
    [user fillWithDictionary:mockUserDictionary];
    
    XCTAssert([user.first_name isEqualToString:mockUserDictionary[@"first_name"]]);
    XCTAssert([user.last_name isEqualToString:mockUserDictionary[@"last_name"]]);
    XCTAssert([user.phone isEqualToString:@""]);
    AMBUserUrlNetworkObject *url = [user.urls firstObject];
    XCTAssert([url.url isEqualToString:mockUserDictionary[@"urls"][0][@"url"]]);
    
    url = nil;
    url = [user urlObjForCampaignID:@123];
    XCTAssert(url);
}

- (void)testSaveAndLoad {
    AMBMockUserObjects *mockUser = [[AMBMockUserObjects alloc] init];
    NSMutableDictionary *mockUserDictionary = [mockUser mockUser];
    AMBUserNetworkObject *user = [[AMBUserNetworkObject alloc] init];
    [user fillWithDictionary:mockUserDictionary];
    
    [user save];
    user = nil;
    user = [AMBUserNetworkObject loadFromDisk];
    
    XCTAssert([user.first_name isEqualToString:mockUserDictionary[@"first_name"]]);
    XCTAssert([user.last_name isEqualToString:mockUserDictionary[@"last_name"]]);
    XCTAssert([user.phone isEqualToString:@""]);
    AMBUserUrlNetworkObject *url = [user.urls firstObject];
    XCTAssert([url.url isEqualToString:mockUserDictionary[@"urls"][0][@"url"]]);
    
    url = nil;
    url = [user urlObjForCampaignID:@123];
    XCTAssert(url);

}


- (void)testAdditionalPusherHeaders {
    AMBPusherSessionSubscribeNetworkObject *o = [[AMBPusherSessionSubscribeNetworkObject alloc] init];
    o.client_session_uid = @"test_session_uid";
    o.channel_name = @"test_channel_name";
    o.expires_at = [NSDate date];
    
    NSMutableDictionary *dictionary = [o additionalNetworkHeaders];
    
    XCTAssertEqualObjects(o.client_session_uid, dictionary[@"X-Mbsy-Client-Session-ID"]);
    XCTAssertNotNil(dictionary[@"X-Mbsy-Client-Request-ID"]);
}

@end
