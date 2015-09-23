//
//  AMBIdentifyNetworkPreferences.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBIdentifyNetworkObject.h"

@interface AMBIdentifyNetworkPreferences : XCTestCase

@end

@implementation AMBIdentifyNetworkPreferences

- (void)setUp { [super setUp]; }

- (void)tearDown { [super tearDown]; }

- (void)testDefaultInit {
    AMBIdentifyNetworkObject *obj = [[AMBIdentifyNetworkObject alloc] init];
    XCTAssertNotNil([obj validate]);
    NSMutableDictionary *json = [obj dictionaryForm];
    XCTAssertNotNil(json);
    XCTAssertEqualObjects(json[@"enroll"], @"");
    XCTAssertEqualObjects(json[@"email"], @"");
    XCTAssertEqualObjects(json[@"campaign_id"], @"");
    XCTAssertEqualObjects(json[@"source"], @"ios_sdk_pilot");
    XCTAssertEqualObjects(json[@"fp"], @{});
}

- (void)testOnlyEmailSet {
    NSString *email = @"jake@getambassador.com";
    AMBIdentifyNetworkObject *obj = [[AMBIdentifyNetworkObject alloc] init];
    obj.email = email;
    XCTAssertNil([obj validate]);
    NSMutableDictionary *json = [obj dictionaryForm];
    XCTAssertNotNil(json);
    XCTAssertEqualObjects(json[@"enroll"], @"");
    XCTAssertEqualObjects(json[@"email"], email);
    XCTAssertEqualObjects(json[@"campaign_id"], @"");
    XCTAssertEqualObjects(json[@"source"], @"ios_sdk_pilot");
    XCTAssertEqualObjects(json[@"fp"], @{});
}

- (void)testOnlyFPSet {
    NSMutableDictionary *fp = [NSMutableDictionary dictionaryWithDictionary:@{ @"key" : @NO }];
    AMBIdentifyNetworkObject *obj = [[AMBIdentifyNetworkObject alloc] init];
    obj.fp = fp;
    XCTAssertNil([obj validate]);
    NSMutableDictionary *json = [obj dictionaryForm];
    XCTAssertNotNil(json);
    XCTAssertEqualObjects(json[@"enroll"], @"");
    XCTAssertEqualObjects(json[@"email"], @"");
    XCTAssertEqualObjects(json[@"campaign_id"], @"");
    XCTAssertEqualObjects(json[@"source"], @"ios_sdk_pilot");
    XCTAssertEqualObjects(json[@"fp"], fp);
}

@end
