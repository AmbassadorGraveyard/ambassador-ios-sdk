//
//  AMBAmbassadorNetworkingTests.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBAmbassadorNetworking.h"

@interface AMBAmbassadorNetworkingTests : XCTestCase

@property NSString *uTok;
@property NSString *uID;

@end

@implementation AMBAmbassadorNetworkingTests

- (void)setUp {
    [super setUp];
    self.uTok = @"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a";
    self.uID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";
}

- (void)testSharedInstance {
    AMBAmbassadorNetworking *obj1 = [AMBAmbassadorNetworking sharedInstance];
    AMBAmbassadorNetworking *obj2 = [AMBAmbassadorNetworking sharedInstance];
    XCTAssertEqual(obj1, obj2);
}

- (void)testSendIdentifyNetworkObj {
    AMBAmbassadorNetworking *obj = [AMBAmbassadorNetworking sharedInstance];
    AMBIdentifyNetworkObject *iObj1 = [[AMBIdentifyNetworkObject alloc] init];
    iObj1.email = @"corey@getambassador.com";
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Send Identify"];
    [obj sendIdentifyNetworkObj:iObj1 universalToken:self.uTok universalID:self.uID completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) {
            XCTFail(@"Send identify failed with error: %@", e.localizedDescription);
            return;
        }
        XCTAssertNil(e);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testSendIdentifyNetworkObjWithBadObj {
    AMBAmbassadorNetworking *obj = [AMBAmbassadorNetworking sharedInstance];
    AMBIdentifyNetworkObject *iObj2 = [[AMBIdentifyNetworkObject alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Send Identify With Bad Object"];
    [obj sendIdentifyNetworkObj:iObj2 universalToken:self.uTok universalID:self.uID completion:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (!e) {
            XCTFail(@"Send identify with bad object failed to return server error");
            return;
        }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
