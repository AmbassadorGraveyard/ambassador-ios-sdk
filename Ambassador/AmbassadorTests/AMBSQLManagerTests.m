//
//  AMBSQLManagerTests.m
//  Ambassador
//
//  Created by Diplomat on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBTests.h"
#import "AMBSQLManager.h"
#import "AMBNetworkObject.h"

@interface AMBSQLManagerTests : AMBTests

@end

@implementation AMBSQLManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    NSError *e;
    AMBSQLManager *o = [[AMBSQLManager alloc] initWithError:&e];
    if (e) {
        NSLog(@"%@", e);
    }
    AMBConversionFields *fields = [[AMBConversionFields alloc] init];

    XCTestExpectation *exp = [self expectationWithDescription:@"Test Save Conversion"];

    [o saveObject:fields ofType:AMBSQLStorageTypeConversions completion:^(NSError *e) {
        if (e) { XCTFail(@"%@",e); }
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
