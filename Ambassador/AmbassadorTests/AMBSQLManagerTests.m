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

- (void)testInsertAndDelete {
    NSError *e;
    AMBSQLManager *o = [[AMBSQLManager alloc] initWithError:&e];
    if (e) { XCTFail(@"%@", e); }
    AMBConversionFields *fields = [[AMBConversionFields alloc] init];
    fields.mbsy_email = @"email@domain.com";

   XCTestExpectation *exp = [self expectationWithDescription:@"Test Insert and Delete"];

    [o stringVersionOfTableType:AMBSQLStorageTypeConversions];

    [o saveObject:fields ofType:AMBSQLStorageTypeConversions completion:^(NSError *e) {
        if (e) { XCTFail(@"%@",e); }
        NSLog(@"saved object");
    }];

    [o selectAllOfType:AMBSQLStorageTypeConversions completion:^(NSMutableArray *results, NSError *e) {
        NSLog(@"blah blah blah%@", results);

        
        for (AMBSQLResult *result in results) {
            [o deleteObjectOfType:AMBSQLStorageTypeConversions withID:result.ID completion:^(NSError *e) {
                [o stringVersionOfTableType:AMBSQLStorageTypeConversions];
                if ([result isEqual:[results lastObject]]) {
                    [exp fulfill];
                }
            }];
        }
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Expectation failed with error: %@", error);
        }
    }];
}

@end
