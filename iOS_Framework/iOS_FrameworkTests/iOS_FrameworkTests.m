//
//  iOS_FrameworkTests.m
//  iOS_FrameworkTests
//
//  Created by Diplomat on 6/11/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "iOS_Framework.h"

@interface iOS_FrameworkTests : XCTestCase

@end

@implementation iOS_FrameworkTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPresentRAFFromController
{
    [Ambassador runWithKey:@"abc123" convertingOnLaunch:nil];
    [Ambassador presentRAFFromViewController:[[UIViewController alloc] init]];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
