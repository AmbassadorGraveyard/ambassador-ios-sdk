//
//  AMBIdentifyTests.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBIdentify.h"

@interface AMBIdentifyTests : XCTestCase
@property NSString *uID;
@property NSString *baseurl;
@end

@implementation AMBIdentifyTests

- (void)setUp {
    [super setUp];
    self.baseurl = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios";
    self.uID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}

- (void)testIdentify {
    AMBIdentify *obj = [[AMBIdentify alloc] init];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify"];
    
    NSString *url = [NSString stringWithFormat:@"%@&universal_id=%@", self.baseurl, self.uID];
    [obj identifyWithURL:url completion:^(NSMutableDictionary *resp, NSError *e) {
        if (e) {
            XCTFail(@"Test idendify failed with error: %@", e);
            return;
        }
        XCTAssertNotNil(resp);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testIdentifyBadUrl {
    AMBIdentify *obj = [[AMBIdentify alloc] init];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify Bad Url"];
    
    NSString *url = [NSString stringWithFormat:@"%@/universal_id=%@", self.baseurl, self.uID];
    [obj identifyWithURL:url completion:^(NSMutableDictionary *resp, NSError *e) {
        if (e) {
            XCTAssertNotNil(e);
            [exp fulfill];
            return;
        }
         XCTFail(@"Test idendify with bad url failed to return server error");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testIdentifyNoUrl {
    AMBIdentify *obj = [[AMBIdentify alloc] init];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify No Url"];
    
    [obj identifyWithURL:@"" completion:^(NSMutableDictionary *resp, NSError *e) {
        if (e) {
            XCTAssertNotNil(e);
            [exp fulfill];
            return;
        }
        XCTFail(@"Test idendify with no url failed to return server error");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
