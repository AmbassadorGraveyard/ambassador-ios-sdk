//
//  AmbassadorSDKTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AmbassadorSDK_Internal.h"
#import "AMBIdentify.h"
#import "AMBValues.h"
#import "AMBConversion.h"
#import "AMBPusherManager.h"
#import <OCMock/OCMock.h>
#import "AMBServiceSelector.h"
#import "AMBNetworkManager.h"
#import "AMBUtilities.h"
#import "AMBNPSViewController.h"

// Testing category made to reveal private methods only in tests
@interface AmbassadorSDK (Tests) <UIAlertViewDelegate>

@property (nonatomic, strong) AMBConversion *conversion;
@property (nonatomic, strong) AMBPusherManager *pusherManager;

- (void)localRunWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID;
- (void)localIdentifyWithUserID:(NSString *)userID traits:(NSDictionary *)traits;
- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist;
- (void)localRegisterConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(ConversionStatus conversionStatus, NSError *error))completion;
- (void)checkConversionQueue;
- (void)sendAPNDeviceToken;
- (void)presentNPSSurvey;

@end


@interface AmbassadorSDKTests : XCTestCase

@property (nonatomic, strong) AmbassadorSDK *ambassadorSDK;
@property (nonatomic) id mockAmbassadorSDK;

@end


@implementation AmbassadorSDKTests

NSString * const universalID = @"test";
NSString * const universalToken = @"test";

- (void)setUp {
    [super setUp];
    if (!self.ambassadorSDK) {
        self.ambassadorSDK = [AmbassadorSDK sharedInstance];
        self.ambassadorSDK.conversion = [[AMBConversion alloc] init];
    }
    
    self.mockAmbassadorSDK = [OCMockObject partialMockForObject:self.ambassadorSDK];
}

- (void)tearDown {
    [self.mockAmbassadorSDK stopMocking];
    [super tearDown];
}

- (void)testSharedInstance {
    XCTAssertNotNil(self.ambassadorSDK);
}

- (void)testClassRunWithKeys {
    // WHEN
    [[self.mockAmbassadorSDK expect] localRunWithuniversalToken:universalToken universalID:universalID];
    [AmbassadorSDK runWithUniversalToken:universalToken universalID:universalID];
    
    // THEN
    [self.mockAmbassadorSDK verify];
}

- (void)testClassIdentify {
    // GIVEN
    NSDictionary *traits = @{@"email": @"ambassadorTest@example.com"};
    NSString *uniqueID = @"1234567890";
    [[self.mockAmbassadorSDK expect] localIdentifyWithUserID:uniqueID traits:traits];
    
    // WHEN
    [AmbassadorSDK identifyWithUserID:uniqueID traits:traits];
    
    // THEN
    [self.mockAmbassadorSDK verify];
}

- (void)testClassRegisterConversion {
    // GIVEN
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = @"test@test.com";
    conversionParameters.mbsy_revenue = @1;
    conversionParameters.mbsy_campaign = @260;
    
    // WHEN
    [[self.mockAmbassadorSDK expect] localRegisterConversion:conversionParameters restrictToInstall:NO completion:[OCMArg isNotNil]];
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:nil];
    
    // THEN
    [self.mockAmbassadorSDK verify];
}

- (void)testClassPresentRAF {
    // GIVEN
    NSString *campID = @"200";
    NSString *plistName = @"GenericTheme";
    UIViewController *mockVC = [[UIViewController alloc] init];
    
    [[self.mockAmbassadorSDK expect] presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    
    // WHEN
    [AmbassadorSDK presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    
    // THEN
    [self.mockAmbassadorSDK verify];
}

- (void)testLocalRunWithKeys {
    // GIVEN
    NSString *completeSDKToken = @"SDKToken test";
    
    id mockConversion = [OCMockObject mockForClass:[AMBConversion class]];
    [[[mockConversion expect] andDo:nil] retryUnsentConversions];
    self.ambassadorSDK.conversion = mockConversion;
    
    // WHEN
    [self.ambassadorSDK localRunWithuniversalToken:universalToken universalID:universalID];
    
    NSString *savedTokenValue = [AMBValues getUniversalToken];
    NSString *savedUnivIDValue = [AMBValues getUniversalID];
    
    // THEN
    XCTAssertEqualObjects(completeSDKToken, savedTokenValue);
    XCTAssertEqualObjects(universalID, savedUnivIDValue);
    XCTAssertNotNil(self.ambassadorSDK.conversion);
    
    [mockConversion verify];
    [mockConversion stopMocking];
}

- (void)testLocalIdentify {
    // GIVEN
    NSString *mockEmail = @"email@email.com";
    NSDictionary *mockTraits = @{@"email" : mockEmail};
    NSString *mockUserID = @"123456789";
    
    [[[self.mockAmbassadorSDK expect] andDo:^(NSInvocation *invocation) {
        void (^success)() = nil;
        [invocation getArgument:&success atIndex:2];
        success();
    }] subscribeToPusherWithSuccess:[OCMArg invokeBlock]];
    
    id mockNtwMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNtwMgr expect] andDo:nil] sendIdentifyForCampaign:[OCMArg isNil] shouldEnroll:NO success:[OCMArg isNotNil] failure:[OCMArg isNotNil]];
    
    // WHEN
    [self.ambassadorSDK localIdentifyWithUserID:mockUserID traits:mockTraits];
    NSString *savedEmail = [AMBValues getUserEmail];
    
    // THEN
    XCTAssertEqualObjects(mockEmail, savedEmail);
    [self.mockAmbassadorSDK verify];
    [mockNtwMgr verify];
    
    [mockNtwMgr stopMocking];
}

- (void)testLocalRegisterConversionNoRestriction {
    // GIVEN
    [AMBValues setMbsyCookieWithCode:@""];
    [AMBValues setDeviceFingerPrintWithDictionary:@{}];
    AMBConversionParameters *mockParams = [[AMBConversionParameters alloc] init];
    mockParams.mbsy_email = @"test@test.com";
    mockParams.mbsy_revenue = @1;
    mockParams.mbsy_campaign = @260;
    id mockConversion = [OCMockObject partialMockForObject:self.ambassadorSDK.conversion];
    
    [[[mockConversion expect] andDo:nil] registerConversionWithParameters:mockParams success:[OCMArg any] pending:[OCMArg any] error:[OCMArg any]];
    
    // WHEN
    [self.ambassadorSDK localRegisterConversion:mockParams restrictToInstall:NO completion:nil];
    
    // THEN
    [mockConversion verify];
}

- (void)testLocalRegisterConversionWithRestriction {
    // GIVEN
    [AMBValues resetHasInstalled];
    
    // WHEN
    [AMBValues setHasInstalled];
    
    // THEN
    XCTAssertTrue([AMBValues getHasInstalledBoolean]);
}

- (void)testLocalPresentRAF {
    // GIVEN
    NSString *campID = @"260";
    NSString *plistName = @"GenericTheme";

    id mockVC = [OCMockObject mockForClass:[AMBServiceSelector class]];
    id mockNav = [OCMockObject mockForClass:[UINavigationController class]];
    id mockSB = [OCMockObject mockForClass:[UIStoryboard class]];

    [[[mockSB expect] andReturn:mockSB] storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    [[[mockSB expect] andReturn:mockNav] instantiateViewControllerWithIdentifier:@"RAFNAV"];
    [[[mockNav expect] andReturn:@[mockVC]] childViewControllers];
    [[[mockVC expect] andDo:nil] setCampaignID:campID];
    [[[mockVC expect] andDo:nil] setThemeName:plistName];
    
    // WHEN
    [[[mockVC expect] andDo:nil] presentViewController:[OCMArg isNotNil] animated:YES completion:nil];
    [self.ambassadorSDK presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    
    // THEN
    [mockVC verify];
}

- (void)testSubscribeToPusher {
    // GIVEN
    [AMBValues setUniversalTokenWithToken:[NSString stringWithFormat:@"SDKToken %@", universalToken]];
    [AMBValues setUniversalIDWithID:universalID];
    self.ambassadorSDK.pusherManager = [[AMBPusherManager alloc] initWithAuthorization:[AMBValues getUniversalToken]];
    
    id pusherMgrMock = [OCMockObject partialMockForObject:self.ambassadorSDK.pusherManager];
    
    // WHEN
    [[pusherMgrMock expect] subscribeToChannel:[OCMArg any] completion:[OCMArg any]];
    
    [self.ambassadorSDK subscribeToPusherWithSuccess:^{
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
            [pusherMgrMock verify];
        }];
    }];
    
    // THEN
    [pusherMgrMock stopMocking];
}

- (void)testClassRegisterDeviceToken {
    // GIVEN
    NSString *deviceToken = @"56d84v64v9a46w4e6846fd4g6dfh46";
    
    // WHEN
    [AmbassadorSDK registerDeviceToken:deviceToken];
    NSString *expectedToken = [AMBValues getAPNDeviceToken];
    
    // THEN
    XCTAssertEqualObjects(deviceToken, expectedToken);
}

- (void)testLocalRegisterDeviceToken {
    // GIVEN
    NSString *deviceToken = @"D4654SD6FAd4f6sdf";
    [AMBValues setAPNDeviceToken:deviceToken];
    [AMBValues setUserEmail:@"test@example.com"];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:nil] updateAPNDeviceToken:deviceToken success:nil failure:nil];
    
    // WHEN
    [[AmbassadorSDK sharedInstance] sendAPNDeviceToken];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
}

- (void)testHandleAmbassadorRemoteNotification {
    // GIVEN
    NSDictionary *mockNotificationDictionary = @{@"TestKey" : @"TestValue"};
    
    id mockApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockApplication expect] andReturn:mockApplication] sharedApplication];
    [[[mockApplication expect] andReturnValue:OCMOCK_VALUE(UIApplicationStateInactive)] applicationState];

    [[[self.mockAmbassadorSDK expect] andDo: nil] presentNPSSurvey];
    
    // WHEN
    [AmbassadorSDK presentNPSSurveyWithNotification:mockNotificationDictionary];
    
    // THEN
    XCTAssertEqual(mockNotificationDictionary, self.ambassadorSDK.notificationData);
    [mockApplication verify];
    [self.mockAmbassadorSDK verify];
    
    [mockApplication stopMocking];
    [self.mockAmbassadorSDK stopMocking];
}

- (void)testPresentNPSSurvey {
    // GIVEN
    id mockNPSVC = [OCMockObject mockForClass:[AMBNPSViewController class]];
    [[[mockNPSVC expect] andReturn:mockNPSVC] alloc];
    mockNPSVC = [[[mockNPSVC expect] andDo:nil] initWithPayload:[OCMArg any]];
    
    id mockTopView = [OCMockObject mockForClass:[UIViewController class]];
    [[[mockTopView expect] andDo:nil] presentViewController:mockNPSVC animated:YES completion:nil];
    
    id mockUtilites = [OCMockObject mockForClass:[AMBUtilities class]];
    [[[mockUtilites expect] andReturn: mockTopView] getTopViewController];
    
    // WHEN
    [self.ambassadorSDK presentNPSSurvey];
    
    // THEN
    [mockNPSVC verify];
    [mockTopView verify];
    [mockUtilites verify];
    
    [mockNPSVC stopMocking];
    [mockTopView stopMocking];
    [mockUtilites stopMocking];
}

- (void)testPresentWelcomeScreen {
    // GIVEN
    [AMBValues setMbsyCookieWithCode:@"fakeCode"];
    
    id mockNtwkMng = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    NSDictionary *returnDict = @{@"image" : @"imagename", @"name" : @"referrerName"};
    [[[mockNtwkMng expect] andDo:^(NSInvocation *invocation) {
        void (^success)(NSDictionary *referrerInfo) = nil;
        [invocation getArgument:&success atIndex:3];
        success(returnDict);
    }] getReferrerInformationWithSuccess:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    AMBWelcomeScreenParameters *fakeParams = [[AMBWelcomeScreenParameters alloc] init];
    
    id mockVC = [OCMockObject mockForClass:[AMBWelcomeScreenViewController class]];
    id mockSB = [OCMockObject mockForClass:[UIStoryboard class]];

    [[[mockSB expect] andReturn:mockSB] storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    [[[mockSB expect] andReturn:mockVC] instantiateViewControllerWithIdentifier:@"WELCOME_SCREEN"];
    [[[mockVC expect] andDo:nil] setParameters:[OCMArg any]];
    [[[mockVC expect] andDo:nil] setReferrerImage:[OCMArg any]];
    [[[mockVC expect] andDo:nil] setReferrerName:[OCMArg any]];
    
    // WHEN
    [AmbassadorSDK presentWelcomeScreen:fakeParams ifAvailable:nil];
    
    // THEN
    [mockVC verify];
    [mockSB verify];
    [mockNtwkMng verify];
    [mockNtwkMng stopMocking];
}


#pragma mark - UIAlertView Delegate Tests

- (void)testAlertViewClickedButton {
    // GIVEN
    id mockAlertView = [OCMockObject mockForClass:[UIAlertView class]];
    
    [[[self.mockAmbassadorSDK expect] andDo:nil] presentNPSSurvey];
    
    // WHEN
    [self.ambassadorSDK alertView:mockAlertView didDismissWithButtonIndex:1];
    
    // THEN
    [self.mockAmbassadorSDK verify];
    
    [mockAlertView stopMocking];
}

@end
