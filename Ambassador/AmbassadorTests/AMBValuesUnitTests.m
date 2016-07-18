//
//  AMBValuesUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/5/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBValues.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBPusherChannelObject.h"
#import "AMBNetworkObject.h"
#import "AMBUtilities.h"

@interface AMBValuesUnitTests : XCTestCase

@end

@implementation AMBValuesUnitTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
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
    XCTAssert(untintedImage.renderingMode == UIImageRenderingModeAutomatic);
}

- (void)testAMBFrameworkBundle {
    // GIVEN
    NSBundle *realBundle;
    NSString *realBundlePath;
    
    // WHEN
    realBundle = [AMBValues AMBframeworkBundle];
    realBundlePath = [realBundle resourcePath];
    
    // THEN
    XCTAssertNotNil(realBundle);}


#pragma mark - URL Tests

- (void)testSendIdentifyURL {
    // GIVEN
    NSString *expectedURL = ([AMBValues isProduction]) ? @"https://api.getambassador.com/universal/action/identify/" : @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/";
    
    // WHEN
    NSString *actualURL = [AMBValues getSendIdentifyUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testShareTrackURL {
    // GIVEN
    NSString *expectedURL = ([AMBValues isProduction]) ? @"https://api.getambassador.com/track/share/" : @"https://dev-ambassador-api.herokuapp.com/track/share/";
    
    // WHEN
    NSString *actualURL = [AMBValues getShareTrackUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testLinkedInAuthURL {
    // GIVEN
    [AMBValues setLinkedInClientID:@"testID"];
    [AMBValues setLinkedInClientSecret:@"testSecret"];
    NSString *expectedURL = @"https://dev-envoy-api.herokuapp.com/oauth/authenticate/?client_id=testID&client_secret=testSecret&provider=linkedin&popup=";
    
    // WHEN
    NSString *actualURL = [AMBValues getLinkedInAuthorizationUrl];
    
    // THEN
    XCTAssertTrue([actualURL containsString:expectedURL]);
}

- (void)testLinkedInShareURL {
    // GIVEN
    [AMBValues setLinkedInClientID:@"testID"];
    [AMBValues setLinkedInClientSecret:@"testSecret"];
    [AMBValues setLinkedInAccessToken:@"fakeToken"];
    NSString *expectedURL = @"https://dev-envoy-api.herokuapp.com/provider/linkedin/share/?client_id=testID&client_secret=testSecret&access_token=fakeToken&message=test";
    
    // WHEN
    NSString *actualURL = [AMBValues getLinkedInShareUrlWithMessage:@"test"];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testBulkShareSMSURL {
    // GIVEN
    NSString *expectedURL = [AMBValues isProduction] ? @"https://api.getambassador.com/share/sms/" : @"https://dev-ambassador-api.herokuapp.com/share/sms/";
    
    // WHEN
    NSString *actualURL = [AMBValues getBulkShareSMSUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testBulkShareEmailURL {
    // GIVEN
    NSString *expectedURL = [AMBValues isProduction] ? @"https://api.getambassador.com/share/email/" : @"https://dev-ambassador-api.herokuapp.com/share/email/";

    // WHEN
    NSString *actualURL = [AMBValues getBulkShareEmailUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testSendConversionURL {
    // GIVEN
    NSString *expectedURL = [AMBValues isProduction] ? @"https://api.getambassador.com/universal/action/conversion/" : @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/";
    
    // WHEN
    NSString *actualURL = [AMBValues getSendConversionUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testPusherSessionURL {
    // GIVEN
    NSString *expectedURL = [AMBValues isProduction] ? @"https://api.getambassador.com/auth/session/" : @"https://dev-ambassador-api.herokuapp.com/auth/session/";
    
    // WHEN
    NSString *actualURL = [AMBValues getPusherSessionUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}

- (void)testPusherAuthURL {
    // GIVEN
    NSString *expectedURL = [AMBValues isProduction] ? @"https://api.getambassador.com/auth/subscribe/" : @"https://dev-ambassador-api.herokuapp.com/auth/subscribe/";
    
    // WHEN
    NSString *actualURL = [AMBValues getPusherAuthUrl];
    
    // THEN
    XCTAssertEqualObjects(expectedURL, actualURL);
}


#pragma mark - Setters and Getters Tests

- (void)testSetAndGetMbsyCookie {
    // GIVEN
    NSString *mockValue = @"testValue";
    
    // WHEN
    [AMBValues setMbsyCookieWithCode:mockValue];
    NSString *realReturnValue = [AMBValues getMbsyCookieCode];
    
    // THEN
    XCTAssertEqualObjects(mockValue, realReturnValue);
}

- (void)testSetAndGetDeviceFingerPrint {
    // GIVEN
    NSDictionary *mockDictionary = @{@"testValue" : @"value"};
    
    // WHEN
    [AMBValues setDeviceFingerPrintWithDictionary:mockDictionary];
    NSDictionary *realReturnValue = [AMBValues getDeviceFingerPrint];
    
    // THEN
    XCTAssertEqualObjects(mockDictionary, realReturnValue);
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
    NSDictionary *mockTraits = @{@"email" : expectedEmail};
    NSString *mockID = @"123456789";
    
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] initWithUserID:mockID traits:mockTraits];
    
    // WHEN
    [AMBValues setUserIdentifyObject:identifyObject];
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

- (void)testSetAndGetAPNDeviceToken {
    // GIVEN
    NSString *apnDeviceToken = @"sdfa65484v86sf5e54v55";
    
    // WHEN
    [AMBValues setAPNDeviceToken:apnDeviceToken];
    NSString *expectedToken = [AMBValues getAPNDeviceToken];
    
    // THEN
    XCTAssertEqualObjects(apnDeviceToken, expectedToken);
}

- (void)testSetAndGetClientID {
    // GIVEN
    NSString *clientID = @"testID";
    
    // WHEN
    [AMBValues setLinkedInClientID:clientID];
    NSString *expectedString = [AMBValues getLinkedInClientID];
    
    // THEN
    XCTAssertEqualObjects(clientID, expectedString);
}

- (void)testSetAndGetClientSecret {
    // GIVEN
    NSString *clientSecret = @"testSecret";
    
    // WHEN
    [AMBValues setLinkedInClientSecret:clientSecret];
    NSString *expectedString = [AMBValues getLinkedInClientSecret];
    
    // THEN
    XCTAssertEqualObjects(clientSecret, expectedString);
}

- (void)testSetAndGetIdentifyObject {
    // GIVEN
    NSString *userId = @"123456789";
    NSString *email = @"test@example.com";
    
    AMBIdentifyNetworkObject *identifyObject = [[AMBIdentifyNetworkObject alloc] initWithUserID:userId traits:@{@"email" : email}];
    
    // WHEN
    [AMBValues setUserIdentifyObject:identifyObject];
    AMBIdentifyNetworkObject *expectedObject = [AMBValues getUserIdentifyObject];
    
    // THEN
    XCTAssertEqualObjects(userId, expectedObject.remote_customer_id);
    XCTAssertEqualObjects(email, expectedObject.email);
}

@end
