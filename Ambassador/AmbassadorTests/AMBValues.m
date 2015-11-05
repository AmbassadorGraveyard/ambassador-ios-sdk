//
//  AMBValues.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/3/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBValues.h"
#import "AMBMockObjects.h"
#import "AmbassadorSDK_Internal.h"

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
//    NSString *imageName = @"spinner";
//    NSString *imageType = @"png";
//    BOOL tintable = YES;
//    BOOL nonTintable = NO;
//    
//    // ACT
//    UIImage *tintedTestImage = [AMBValues imageFromBundleWithName:imageName type:imageType tintable:tintable];
//    UIImage *untintedTestImage = [AMBValues imageFromBundleWithName:imageName type:imageType tintable:nonTintable];
//    
//    // ASSERT
//    XCTAssert(tintedTestImage.renderingMode == UIImageRenderingModeAlwaysTemplate);
//    XCTAssertEqual(untintedTestImage.renderingMode, UIImageRenderingModeAutomatic);
}

- (void)testAmbFrameworkBundle {
    // ARRANGE
//    NSString *mockBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ambassador.bundle"];
//    
//    // ACT
//    NSBundle *frameworkBundle = [AMBValues AMBframeworkBundle];
//    
//    // ASSERT
//    XCTAssertFalse([mockBundlePath isEqualToString:frameworkBundle.bundlePath]);
//    XCTAssertTrue([mockBundlePath isEqualToString:frameworkBundle.bundlePath], @"Expected %@ is equal to %@", mockBundlePath, [AMBMockObject mockAmbBundle].resourceURL);
}

- (void)testIdentifyURL {
    // ARRANGE
    NSString *mockSessionID = @"thisisafakechannelabcdefghijklmnop";
    NSString *mockUniversalID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";
    NSString *mockRequestID;
    NSString *mockDevURL;
    [AmbassadorSDK sharedInstance].pusherChannelObj.sessionId = mockSessionID;
    
    // ACT
    NSString *identifyURL = [AMBValues identifyUrlWithUniversalID:mockUniversalID];
    mockRequestID = [AmbassadorSDK sharedInstance].pusherChannelObj.requestId;
    mockDevURL = [NSString stringWithFormat:@"https://staging.mbsy.co/universal/landing?url=ambassador:ios&universal_id=%@&mbsy_client_session_id=%@&mbsy_client_request_id=%@", mockUniversalID, mockSessionID, mockRequestID];
    
    // ASSERT
    XCTAssert([mockDevURL isEqualToString:identifyURL], @"Expect %@ to equal %@", mockDevURL, identifyURL);
}

- (void)testSetAndGetMbsyCookie {
    // ARRANGE
    NSString *mockSuiteName = @"AMBDEFAULTS";
    NSString *mockSaveKey = @"mbsy_cookie_code";
    NSString *mockValue = @"testValue";
    NSUserDefaults *mockDefaults = [[NSUserDefaults alloc] initWithSuiteName:mockSuiteName];
    
    NSString *mockReturnValue;
    NSString *realReturnValue;
    
    // ACT
    [mockDefaults setValue:mockValue forKey:mockSaveKey];
    [AMBValues setMbsyCookieWithCode:mockValue];
    
    mockReturnValue = [mockDefaults valueForKey:mockSaveKey];
    realReturnValue = [AMBValues getMbsyCookieCode];
    
    // ASSERT
    XCTAssertEqual(mockReturnValue, realReturnValue);
}


@end
