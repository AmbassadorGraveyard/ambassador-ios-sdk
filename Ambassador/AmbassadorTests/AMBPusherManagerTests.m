//
//  AMBPusherManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBPusherManager.h"

@interface AMBPusherManagerTests : XCTestCase

@end

@implementation AMBPusherManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSubscribeAndBind {
    AMBPusherManager *obj = [[AMBPusherManager alloc] initWith:@"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a" universalID:@"abfd1c89-4379-44e2-8361-ee7b87332e32"];
    
     XCTestExpectation *exp = [self expectationWithDescription:@"Test Subscribe/Bind To Pusher"];
    
    [obj subscribe:@"4785d68586b2731afb1ac61ede0348245e7e117bda4aa44ef379e9b466f7426eba6f5812f699b02da0dea73dffad356f" completion:^(AMBPTPusherChannel *chan, NSError *e) {
        if (e) {
            XCTFail(@"Expectation failed with error: %@", e);
        }
        [obj bindToChannelEvent:@"ios_auto_tests" handler:^(AMBPTPusherEvent *ev) {}];
        
        XCTAssertNotNil(chan);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
