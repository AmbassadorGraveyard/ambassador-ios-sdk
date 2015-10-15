//
//  AMBAmbassadorNetworkManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBAmbassadorNetworkManager.h"
#import "AMBNetworkObject.h"

@interface AMBAmbassadorNetworkManagerTests : XCTestCase
@property NSString *uTok;
@property NSString *uID;
@end

@implementation AMBAmbassadorNetworkManagerTests

- (void)setUp {
    [super setUp];
    self.uTok = @"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a";
    self.uID = @"";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPusherSessionSubscribe {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify"];
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:[AMBAmbassadorNetworkManager pusherSessionSubscribeUrl] universalToken:self.uTok universalID:self.uID completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) {
            XCTFail(@"%@", e);
        } else {
            NSUInteger code = ((NSHTTPURLResponse *)r).statusCode;
            XCTAssert(code >= 200 && code < 300);
            
            AMBPusherSessionSubscribeNetworkObject* o = [[AMBPusherSessionSubscribeNetworkObject alloc] init];
            NSError *err;
            [o fillWithDictionary:[NSJSONSerialization JSONObjectWithData:d options:0 error:&err]];
            if (err) { XCTFail(@"%@", err); }
            
            XCTAssertNotNil(o.channel_name);
            XCTAssertNotNil(o.expires_at);
            XCTAssertNotNil(o.client_session_uid);
            NSLog(@"%@\n%@\n%@",o.channel_name, o.expires_at, o.client_session_uid);
            
            [exp fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
