//
//  AMBPusherManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBPusherManager.h"
#import "AMBTests.h"

@interface AMBPusherManagerTests : AMBTests
@property NSString *channelName;
@end

@implementation AMBPusherManagerTests

- (void)setUp {
    [super setUp];
    self.channelName = @"test_channel";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDevPusherSubscribe {
    XCTFail();
//    XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Pusher Auth Subscribe"];
//    AMBPusherManager *o = [AMBPusherManager sharedInstanceWithAuthorization:self.devToken];
//    [o subscribeTo:self.channelName completion:^(AMBPTPusherChannel *c, NSError *e) {
//        if (e) { XCTFail(@"%@",e); }
//        XCTAssertNotNil(c);
//        [exp fulfill];
//        
//    }];
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//        if (error) {
//            XCTFail(@"Expectation failed with error: %@", error);
//        }
//    }];
}

- (void)testProdPusherSubscribe {
    XCTFail();
//    XCTestExpectation *exp = [self expectationWithDescription:@"Test Prod Pusher Auth Subscribe"];
//    AMBPusherManager *o = [AMBPusherManager sharedInstanceWithAuthorization:self.prodToken];
//    [o subscribeTo:self.channelName completion:^(AMBPTPusherChannel *c, NSError *e) {
//        if (e) { XCTFail(@"%@", e); }
//        XCTAssertNotNil(c);
//        [exp fulfill];
//        
//    }];
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//        if (error) {
//            XCTFail(@"Expectation failed with error: %@", error);
//        }
//    }];
}

@end
