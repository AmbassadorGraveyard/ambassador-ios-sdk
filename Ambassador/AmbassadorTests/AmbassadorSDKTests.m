//
//  AmbassadorSDKTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBTests.h"
#import "AmbassadorSDK_Internal.h"

@interface AmbassadorSDKTests : AMBTests
@end

@implementation AmbassadorSDKTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDevSendIdentify {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Send Identify"];
    [AmbassadorSDK sendIdentifyWithEmail:@"jake@getambassador.com" campaign:@"260" enroll:YES universalToken:self.devToken universalID:self.devID completion:^(NSError *e) {
        if (e) { XCTFail(@"%@", e); }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

//- (void)testProdSendIdentify {
//    XCTFail(); // NEEDS TO FLIP URLS FOR PROD
////    XCTestExpectation *exp = [self expectationWithDescription:@"Test Prod Send Identify"];
////    [AmbassadorSDK sendIdentifyWithEmail:@"jake@getambassador.com" campaign:@"260" enroll:YES universalToken:self.prodToken universalID:self.prodID completion:^(NSError *e) {
////        if (e) { XCTFail("%@", e); }
////        [exp fulfill];
////    }];
////    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
////        if (error) {
////            XCTFail(@"Expectation failed with error: %@", error);
////        }
////    }];
//}

- (void)testDevPusherChannel {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Pusher Channel"];
    [AmbassadorSDK pusherChannelUniversalToken:self.devToken universalID:self.devID completion:^(NSString *s, NSError *e) {
        if (e) { XCTFail(@"%@", e); }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testPusher {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Dev Pusher Channel"];
    [AmbassadorSDK runWithUniversalToken:self.devToken universalID:self.devID];
    [AmbassadorSDK identifyWithEmail:@"jake@getambassador.com" completion:^(NSError *e) {
        if (e) { XCTFail(@"%@",e); }
        [AmbassadorSDK startPusherUniversalToken:self.devToken universalID:self.devID completion:^(AMBPTPusherChannel *chan, NSError *e) {
            if (e) { XCTFail(@"%@",e); }
            
            [AmbassadorSDK bindToIdentifyActionUniversalToken:self.devToken universalID:self.devID];
            
            [AmbassadorSDK sendIdentifyWithEmail:@"jake@getambassador.com" campaign:nil enroll:NO universalToken:self.devToken universalID:self.devID completion:^(NSError *e) {
                if (e) { XCTFail(@"%@",e); }
                
                [exp fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
