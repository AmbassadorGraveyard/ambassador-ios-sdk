//
//  AMBValuesUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/5/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBValues.h"
#import "AmbassadorSDK_Internal.h"
#import <OCMock/OCMock.h>

@interface AMBValuesUnitTests : XCTestCase

@end

@implementation AMBValuesUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testImageFromBundle {
    // ARRANGE
//    id valuesMock = OCMClassMock([AMBValues class]);
//    
//    
////    id mockBundle = OCMClassMock([NSBundle class]);
//    
//    UIImage *tintedImage;
//    UIImage *untintedImage;
//    NSString *mockImageName = @"spinner";
//    NSString *mockFileType = @"png";
//    
//    BOOL shouldTint = YES;
//    BOOL shouldNotTint = NO;
//    
//    // ACT
//    OCMStub([valuesMock ])
//    
//     ASSERT
//    XCTAssertTrue(tintedImage.renderingMode == UIImageRenderingModeAlwaysTemplate);
}

@end
