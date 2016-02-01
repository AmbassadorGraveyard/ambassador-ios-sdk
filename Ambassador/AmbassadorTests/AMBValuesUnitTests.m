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
#import "AMBPusherChannelObject.h"
#import "AMBNetworkObject.h"

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


#pragma mark - Images Tests

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


#pragma mark - Setters and Getters Tests

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

- (void)testSetAndGetUserEmail {
    // GIVEN
    NSString *expectedEmail = @"user@example.com";
    
    // WHEN
    [AMBValues setUserEmail:expectedEmail];
    NSString *savedEmail = [AMBValues getUserEmail];
    
    // THEN
    XCTAssertEqualObjects(expectedEmail, savedEmail);
}

- (void)testSetAndGetPusherChannelObject {
    // GIVEN
    NSDictionary *expectedDict = @{ @"channel_name" : @"lsdfjsdlfkj@snippet-channel", @"client_session_uid" : @"lsdfjsdlfkj", @"expires_at" : @"2016-02-01T01:01:01.123" };
    
    // WHEN
    [AMBValues setPusherChannelObject:expectedDict];
    AMBPusherChannelObject *savedObject = [AMBValues getPusherChannelObject];
    
    // THEN
    XCTAssertEqualObjects(expectedDict[@"channel_name"], savedObject.channelName);
    XCTAssertEqualObjects(expectedDict[@"client_session_uid"], savedObject.sessionId);
    XCTAssertNotNil(savedObject.expiresAt);
}

- (void)testSetAndGetUserURLObject {
    // GIVEN
    NSDictionary *expectedDict = @{ @"campaign_uid" : @"123456789",
                                    @"short_code" : @"TeSt",
                                    @"subject" : @"Unit test line",
                                    @"url" : @"mbsy.co.test/TeSt",
                                    @"has_access" : @1,
                                    @"is_active" : @1 };
    
    // WHEN
    [AMBValues setUserURLObject:expectedDict];
    AMBUserUrlNetworkObject *savedObject = [AMBValues getUserURLObject];
    
    // THEN
    XCTAssertEqualObjects(expectedDict[@"campaign_uid"], savedObject.campaign_uid);
    XCTAssertEqualObjects(expectedDict[@"short_code"], savedObject.short_code);
    XCTAssertEqualObjects(expectedDict[@"subject"], savedObject.subject);
    XCTAssertEqualObjects(expectedDict[@"url"], savedObject.url);
    XCTAssertTrue(savedObject.has_access);
    XCTAssertTrue(savedObject.is_active);
}

@end
