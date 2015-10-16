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

@interface AMBNetworObjectTests : XCTestCase

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


@end
