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

@interface AMBValuesUnitTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *mockDefaults;

@end

@implementation AMBValuesUnitTests

- (void)setUp {
    [super setUp];
    self.mockDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"AMBDEFAULTS"];
}

- (void)tearDown {
    [self.mockDefaults removeSuiteNamed:@"AMBDEFAULTS"];
    [super tearDown];
}

- (void)testImageFromBundle {
    // GIVEN
    UIImage *tintedImage;
    UIImage *untintedImage;
    NSString *imageName = @"unitTestImage";
    NSString *imageExtension = @"png";
    BOOL tinted = YES;
    BOOL untinted = NO;
    
    // WHEN
    tintedImage = [AMBValues imageFromBundleWithName:imageName type:imageExtension tintable:tinted];
    untintedImage = [AMBValues imageFromBundleWithName:imageName type:imageExtension tintable:untinted];
    
    // THEN
    XCTAssertNotNil(tintedImage);
    XCTAssertNotNil(untintedImage);
    XCTAssert(tintedImage.renderingMode == UIImageRenderingModeAlwaysTemplate);
    XCTAssert(untintedImage.renderingMode == UIImageRenderingModeAutomatic);
}

- (void)testAMBFrameworkBundle {
    // GIVEN
    NSBundle *mockBundle = [NSBundle bundleForClass:[self class]];
    NSString *mockBundlePath = [mockBundle resourcePath];
    NSBundle *realBundle;
    NSString *realBundlePath;
    
    // WHEN
    realBundle = [AMBValues AMBframeworkBundle];
    realBundlePath = [realBundle resourcePath];
    
    // THEN
    XCTAssertNotNil(realBundle);
    XCTAssertEqual(mockBundle, realBundle);
    XCTAssert([mockBundlePath isEqualToString:realBundlePath], @"Expected %@, but got %@", mockBundlePath, realBundlePath);
}

- (void)testSetAndGetMbsyCookie {
    // GIVEN
    NSString *mockSaveKey = @"mbsy_cookie_code";
    NSString *mockValue = @"testValue";
    
    NSString *mockReturnValue;
    NSString *realReturnValue;
    
    // WHEN
    [self.mockDefaults setValue:mockValue forKey:mockSaveKey];
    [AMBValues setMbsyCookieWithCode:mockValue];
    
    mockReturnValue = [self.mockDefaults valueForKey:mockSaveKey];
    realReturnValue = [AMBValues getMbsyCookieCode];
    
    // THEN
    XCTAssertEqualObjects(mockReturnValue, realReturnValue);
}

- (void)testSetAndGetDeviceFingerPrint {
    // GIVEN
    NSString *mockSaveKey = @"device_fingerprint";
    NSDictionary *mockDictionary = @{@"testValue" : @"value"};
    
    NSDictionary *mockReturnValue;
    NSDictionary *realReturnValue;
    
    // WHEN
    [self.mockDefaults setValue:mockDictionary forKey:mockSaveKey];
    [AMBValues setDeviceFingerPrintWithDictionary:mockDictionary];
    
    mockReturnValue = [self.mockDefaults valueForKey:mockSaveKey];
    realReturnValue = [AMBValues getDeviceFingerPrint];
    
    // THEN
    XCTAssertEqualObjects(mockReturnValue, realReturnValue);
}

- (void)testSetAndGetHasInstalled {
    // GIVEN
    BOOL notFirstLaunch = YES;
    
    // WHEN
    [AMBValues setHasInstalled];
    BOOL expectedTrueBool = [AMBValues getHasInstalledBoolean];
    
    // THEN
    XCTAssertEqual(notFirstLaunch, expectedTrueBool);
}

- (void)testSetAndGetUniversalID {
    // GIVE
    NSString *mockUniversalID = @"testID";
    
    // WHEN
    [AMBValues setUniversalIDWithID:mockUniversalID];
    NSString *expectedID = [AMBValues getUniversalID];
    
    // THEN
    XCTAssertEqualObjects(mockUniversalID, expectedID);
}

- (void)testSetAndGetUniversalToken {
    // GIVEN
    NSString *mockUniversalToken = @"testToken";
    
    // WHEN
    [AMBValues setUniversalTokenWithToken:mockUniversalToken];
    NSString *expectedToken = [AMBValues getUniversalToken];
    
    // THEN
    XCTAssertEqualObjects(mockUniversalToken, expectedToken);
}

- (void)testSetAndGetUserFirstName {
    // GIVEN
    NSString *mockFirstName = @"userFirstName";
    
    // WHEN
    [AMBValues setUserFirstNameWithString:mockFirstName];
    NSString *expectedFirstName = [AMBValues getUserFirstName];
    
    // THEN
    XCTAssertEqualObjects(mockFirstName, expectedFirstName);
}

- (void)testSetAndGetUserLastName {
    // GIVEN
    NSString *mockLastName = @"userLastName";
    
    // WHEN
    [AMBValues setUserLastNameWithString:mockLastName];
    NSString *expectedLastName = [AMBValues getUserLastName];
    
    // THEN
    XCTAssertEqualObjects(mockLastName, expectedLastName);
}

- (void)testSetAndGetLinkedInExpirationDate {
    // GIVEN
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *mockDate = [formatter dateFromString:@"2016-02-06 20:39:59"];
    
    // WHEN
    [AMBValues setLinkedInExpirationDate:mockDate];
    NSDate *expectedDate = [AMBValues getLinkedInTokenExirationDate];
    
    // THEN
    XCTAssertEqualObjects(mockDate, expectedDate);
}

- (void)testSetAndGetLinkedInAccessToken {
    // GIVEN
    NSString *mockAccessToken = @"randomaccesstoken6546";
    
    // WHEN
    [AMBValues setLinkedInAccessToken:mockAccessToken];
    NSString *expectedAccessToken = [AMBValues getLinkedInAccessToken];
    
    // THEN
    XCTAssertEqualObjects(mockAccessToken, expectedAccessToken);
}

@end
