//
//  AMBCoreDataManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBCoreDataManager.h"
#import "AMBConversionFieldsNetworkObject.h"

@interface AMBCoreDataManagerTests : XCTestCase
@property AMBConversionFieldsNetworkObject *netObj;
@end

@implementation AMBCoreDataManagerTests

- (void)setUp {
    [super setUp];
    self.netObj = [[AMBConversionFieldsNetworkObject alloc] init];
    self.netObj.mbsy_campaign = @"260";
    self.netObj.mbsy_email = @"jake@getambassador.com";
    self.netObj.mbsy_revenue = @1;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveIdentify {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Save Identify"];
    
    AMBCoreDataManager *obj = [[AMBCoreDataManager alloc] init];
    [obj saveIdentifyData:[[AMBIdentifyNetworkObject alloc] init] completion:^(NSError *e) {
        if (e) {
            XCTFail(@"falied with error %@", e);
        }
        XCTAssertNil(e);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testSaveConversion {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Save Identify"];
    
    AMBCoreDataManager *obj = [[AMBCoreDataManager alloc] init];
    [obj saveConversionFields:self.netObj completion:^(NSError *e) {
        if (e) {
            XCTFail(@"falied with error %@", e);
        }
        XCTAssertNil(e);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

- (void)testGetEntityAndRemove {
    XCTestExpectation *exp = [self expectationWithDescription:@"Test Save Identify"];
    
    AMBCoreDataManager *obj = [[AMBCoreDataManager alloc] init];
    [obj saveIdentifyData:[[AMBIdentifyNetworkObject alloc] init] completion:^(NSError *e) {
        if (e) {
            XCTFail(@"falied with error %@", e);
        }
        [obj getEntity:@"AMBIdentifyCoreDataObject" completion:^(NSArray *results, NSError *e) {
            if (e) {
                XCTFail(@"falied with error %@", e);
            }
            XCTAssert(results.count == 1);
            [obj saveIdentifyData:[[AMBIdentifyNetworkObject alloc] init] completion:^(NSError *e) {
                if (e) {
                    XCTFail(@"falied with error %@", e);
                }
                [obj getEntity:@"AMBIdentifyCoreDataObject" completion:^(NSArray *results, NSError *e) {
                    if (e) {
                        XCTFail(@"falied with error %@", e);
                    }
                    XCTAssert(results.count == 1);
                    [exp fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
