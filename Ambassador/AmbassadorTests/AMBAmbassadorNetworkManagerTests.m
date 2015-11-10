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
#import "AMBTests.h"
#import "AMBMockObjects.h"

@interface AMBAmbassadorNetworkManagerTests : AMBTests
@end


@implementation AMBAmbassadorNetworkManagerTests
- (void)setUp {
    [super setUp];
    self.devToken = [NSString stringWithFormat:@"SDKToken %@",self.devToken];
    self.prodToken = [NSString stringWithFormat:@"SDKToken %@",self.prodToken];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSendNetworkObject {
    
}


//- (void)testDevPusherSessionSubscribe {
//    XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Pusher Session Subscribe"];
//    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:[AMBAmbassadorNetworkManager pusherSessionSubscribeUrl] universalToken:self.devToken universalID:self.devID additionParams:nil completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//        if (e) {
//            XCTFail(@"%@", e);
//        } else {
//            NSUInteger code = ((NSHTTPURLResponse *)r).statusCode;
//            XCTAssert(code >= 200 && code < 300);
//            
//            AMBPusherSessionSubscribeNetworkObject* o = [[AMBPusherSessionSubscribeNetworkObject alloc] init];
//            NSError *err;
//            [o fillWithDictionary:[NSJSONSerialization JSONObjectWithData:d options:0 error:&err]];
//            if (err) { XCTFail(@"%@", err); }
//            
//            XCTAssertNotNil(o.channel_name);
//            XCTAssertNotNil(o.expires_at);
//            XCTAssertNotNil(o.client_session_uid);
//            
//            [exp fulfill];
//        }
//    }];
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//        if (error) {
//            XCTFail(@"Expectation failed with error: %@", error);
//        }
//    }];
//}

//- (void)testProdPusherSessionSubscribe {
//    XCTFail();
//    XCTestExpectation *exp = [self expectationWithDescription:@"Test Prod Pusher Session Subscribe"];
//    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nil url:[AMBAmbassadorNetworkManager pusherSessionSubscribeUrl] universalToken:self.prodToken universalID:self.prodID  additionParams:nil completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//        if (e) {
//            XCTFail(@"%@", e);
//        } else {
//            NSUInteger code = ((NSHTTPURLResponse *)r).statusCode;
//            XCTAssert(code >= 200 && code < 300);
//            
//            AMBPusherSessionSubscribeNetworkObject* o = [[AMBPusherSessionSubscribeNetworkObject alloc] init];
//            NSError *err;
//            [o fillWithDictionary:[NSJSONSerialization JSONObjectWithData:d options:0 error:&err]];
//            if (err) { XCTFail(@"%@", err); }
//            
//            XCTAssertNotNil(o.channel_name);
//            XCTAssertNotNil(o.expires_at);
//            XCTAssertNotNil(o.client_session_uid);
//            NSLog(@"%@\n%@\n%@",o.channel_name, o.expires_at, o.client_session_uid);
//            
//            [exp fulfill];
//        }
//    }];
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//        if (error) {
//            XCTFail(@"Expectation failed with error: %@", error);
//        }
//    }];
//}

//- (void)testDevSendValidShareTrackObjects {
//    NSArray *objs = @[
//                      [AMBMockShareTrackObject validEmailShare],
//                      [AMBMockShareTrackObject validSMSShare],
//                      [AMBMockShareTrackObject validLinkedInShare],
//                      [AMBMockShareTrackObject validTwitterShare],
//                      [AMBMockShareTrackObject validFacebookShare]
//                      ];
//
//    for (AMBShareTrackNetworkObject *obj in objs) {
//        [obj toDictionary];
//        XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Send Valid Share Track Object"];
//        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:obj url:[AMBAmbassadorNetworkManager sendShareTrackUrl] universalToken:self.devToken universalID:self.devID additionParams:nil completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//            if (e) {
//                NSLog(@"%@ - %@", obj.social_name, e);
//                return;
//            }
//            [exp fulfill];
//        }];
//        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//            if (error) {
//                XCTFail(@"Expectation failed with error: %@", error);
//            }
//        }];
//    }
//}

//- (void)testDevInvalidShareTrackObjects {
//    NSArray *objs = @[
//                      //[AMBMockShareTrackObject invalidRecipientUsernameShare],
//                      [AMBMockShareTrackObject invalidServiceTypeShare],
//                      [AMBMockShareTrackObject invalidShortCodeShare],
//                      //[AMBMockShareTrackObject invalidRecipientEmailShare]
//                      ];
//
//    for (AMBShareTrackNetworkObject *obj in objs) {
//        [obj toDictionary];
//        XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Send Valid Share Track Object"];
//        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:obj url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//            if (!e) {
//                NSLog(@"%@ didn't throw an error though it should. Here's the data - %@", obj.social_name, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
//
//                return;
//            }
//            [exp fulfill];
//        }];
//        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
//            if (error) {
//                XCTFail(@"Expectation failed with error: %@", error);
//            }
//        }];
//    }
//}

@end
