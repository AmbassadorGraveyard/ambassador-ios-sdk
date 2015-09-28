//
//  AmbassadorSDKTests.m
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AmbassadorSDK.h"


@interface AmbassadorSDKTests : XCTestCase
@property NSString *uTok;
@property NSString *uID;
@property AMBConversionFieldsNetworkObject *netObj;
@end

@implementation AmbassadorSDKTests

- (void)setUp {
    [super setUp];
    self.uTok = @"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a";
    self.uID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";
    self.netObj = [[AMBConversionFieldsNetworkObject alloc] init];
    self.netObj.mbsy_campaign = @"260";
    self.netObj.mbsy_email = @"ja@o.com";
    self.netObj.mbsy_revenue = @1;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testIdentify {
   // [self measureBlock:^{
        XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify"];
        
        [AmbassadorSDK ambassadorWithUniversalToken:self.uTok universalID:self.uID];
        [AmbassadorSDK identify:@"jake@getambassador.com" completion:^(NSError *e) {
            if (e) {
                XCTFail(@"Expectation failed with error: %@", e);
            }
            [exp fulfill];
        }];
        [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * __nullable error) {
            if (error) {
                XCTFail(@"Expectation failed with error: %@", error);
            }
        }];
   // }];
}

- (void)testConversion {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Register Conversion"];
    
    [AmbassadorSDK ambassadorWithUniversalToken:self.uTok universalID:self.uID];
    [AmbassadorSDK conversion:self.netObj completion:^(NSError *e) {
        if (e) {
            XCTFail(@"Expectation failed with error: %@", e);
        }
        [exp fulfill];

    }];
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testIdentifyToConversionFiring {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Identify To Conversion Firing"];
    
    [AmbassadorSDK ambassadorWithUniversalToken:self.uTok universalID:self.uID];
    [AmbassadorSDK identify:@"jake@getambassador.com" completion:^(NSError * e) {
        if (e) {
            XCTFail(@"Expectation failed with error: %@", e);
        } else {
            [AmbassadorSDK conversion:self.netObj completion:^(NSError *e) {
                if (e) {
                    XCTFail(@"Expectation failed with error: %@", e);
                } else {
                    [AmbassadorSDK sendConversions:self.uTok universalID:self.uID completion:^(NSError *e) {
                        if (e) {
                            XCTFail(@"Expectation failed with error: %@", e);
                        } else {
                            [exp fulfill];
                        }
                    }];
                }
            }];
        }
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
