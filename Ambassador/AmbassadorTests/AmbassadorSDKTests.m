//
//  AmbassadorSDKTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBTests.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBIdentify.h"
#import "AMBValues.h"
#import "AMBConversion.h"
#import "AMBPusherManager.h"
#import <OCMock/OCMock.h>

// Testing category made to reveal private methods only in tests
@interface AmbassadorSDK (Tests)

@property (nonatomic, strong) AMBConversion *conversion;
@property (nonatomic, strong) AMBPusherManager *pusherManager;

- (void)localRunWithuniversalToken:(NSString *)universalToken universalID:(NSString *)universalID;
- (void)localIdentifyWithEmail:(NSString*)email;
- (void)presentRAFForCampaign:(NSString *)ID FromViewController:(UIViewController *)viewController withThemePlist:(NSString*)themePlist;
- (void)localRegisterConversion:(AMBConversionParameters *)conversionParameters restrictToInstall:(BOOL)restrictToInstall completion:(void (^)(NSError *error))completion;
- (void)checkConversionQueue;

@end


@interface AmbassadorSDKTests : AMBTests

@property (nonatomic, strong) AmbassadorSDK *ambassadorSDK;

@end


@implementation AmbassadorSDKTests

NSString * const universalID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";
NSString * const universalToken = @"9de5757f801ca60916599fa3f3c92131b0e63c6a";

- (void)setUp {
    [super setUp];
    if (!self.ambassadorSDK) {
        self.ambassadorSDK = [AmbassadorSDK sharedInstance];
        self.ambassadorSDK.conversion = [[AMBConversion alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSharedInstance {
    XCTAssertNotNil(self.ambassadorSDK);
}

- (void)testClassRunWithKeys {
    // GIVEN
    id ambassadorSDKMock = [OCMockObject partialMockForObject:self.ambassadorSDK];
    
    // WHEN
    [[ambassadorSDKMock expect] localRunWithuniversalToken:universalToken universalID:universalID];
    [AmbassadorSDK runWithUniversalToken:universalToken universalID:universalID];
    
    // THEN
    [ambassadorSDKMock verify];
}

- (void)testClassIdentify {
    // GIVEN
    id ambassadorSDKMock = [OCMockObject partialMockForObject:self.ambassadorSDK];
    NSString *fakeEmail = @"ambassadorTest@example.com";
    
    // WHEN
    [[ambassadorSDKMock expect] localIdentifyWithEmail:fakeEmail];
    [AmbassadorSDK identifyWithEmail:fakeEmail];
    
    // THEN
    [ambassadorSDKMock verify];
}

- (void)testClassRegisterConversion {
    // GIVEN
    id ambassadorSDKMock = [OCMockObject partialMockForObject:self.ambassadorSDK];
    
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = @"test@test.com";
    conversionParameters.mbsy_revenue = @1;
    conversionParameters.mbsy_campaign = @260;
    
    // WHEN
    [[ambassadorSDKMock expect] localRegisterConversion:conversionParameters restrictToInstall:NO completion:nil];
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:nil];
    
    // THEN
    [ambassadorSDKMock verify];
}

- (void)testClassPresentRAF {
    // GIVEN
    id ambassadorSDKMock = [OCMockObject partialMockForObject:self.ambassadorSDK];
    NSString *campID = @"200";
    NSString *plistName = @"GenericTheme";
    UIViewController *mockVC = [[UIViewController alloc] init];
    
    // WHEN
    [[ambassadorSDKMock expect] presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    [AmbassadorSDK presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    
    // THEN
    [ambassadorSDKMock verify];
}

- (void)testLocalRunWithKeys {
    // GIVEN
    NSString *completeSDKToken = @"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a";
    
    // WHEN
    [self.ambassadorSDK localRunWithuniversalToken:universalToken universalID:universalID];
    
    NSString *savedTokenValue = [AMBValues getUniversalToken];
    NSString *savedUnivIDValue = [AMBValues getUniversalID];
    
    // THEN
    XCTAssertEqualObjects(completeSDKToken, savedTokenValue);
    XCTAssertEqualObjects(universalID, savedUnivIDValue);
}

- (void)testLocalIdentify {
    // GIVEN
    NSString *mockEmail = @"email@email.com";
    
    // WHEN
    [self.ambassadorSDK localIdentifyWithEmail:mockEmail];
    NSString *savedEmail = [AMBValues getUserEmail];
    
    // THEN
    XCTAssertEqualObjects(mockEmail, savedEmail);
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
    
    // WHEN
    [[mockConversion expect] registerConversionWithParameters:mockParams completion:[OCMArg any]];
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
    UIViewController *mockController = [[UIViewController alloc] init];
    id mockVC = [OCMockObject partialMockForObject:mockController];
    
    // WHEN
    [[mockVC expect] presentViewController:[OCMArg isNotNil] animated:YES completion:nil];
    [self.ambassadorSDK presentRAFForCampaign:campID FromViewController:mockVC withThemePlist:plistName];
    
    // THEN
    [mockVC verify];
}

- (void)testCheckConversionQueue {
    // GIVEN
    [AMBValues setMbsyCookieWithCode:@""];
    [AMBValues setDeviceFingerPrintWithDictionary:@{}];
    id conversionMock = [OCMockObject partialMockForObject:self.ambassadorSDK.conversion];
    
    // WHEN
    [[conversionMock expect] sendConversions];
    [self.ambassadorSDK checkConversionQueue];
    
    // THEN
    [conversionMock verify];
}

- (void)testSubscribeToPusher {
    // GIVEN
    [AMBValues setUniversalTokenWithToken:[NSString stringWithFormat:@"SDKToken %@", universalToken]];
    [AMBValues setUniversalIDWithID:universalID];
    self.ambassadorSDK.pusherManager = [AMBPusherManager sharedInstanceWithAuthorization:[AMBValues getUniversalToken]];

    id pusherMgrMock = [OCMockObject partialMockForObject:self.ambassadorSDK.pusherManager];
    
    // WHEN
    [[pusherMgrMock expect] subscribeToChannel:[OCMArg any] completion:[OCMArg any]];
    
    [self.ambassadorSDK subscribeToPusherWithCompletion:^{
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
            [pusherMgrMock verify];
        }];
    }];
}

@end
