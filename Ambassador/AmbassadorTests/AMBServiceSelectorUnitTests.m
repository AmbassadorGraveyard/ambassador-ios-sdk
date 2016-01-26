//
//  AMBServiceSelectorUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBServiceSelector.h"
#import <OCMock/OCMock.h>
#import "AMBNetworkObject.h"
#import "AMBContactSelector.h"
#import "AMBAuthorizeLinkedIn.h"
#import "AMBThemeManager.h"
#import "AMBNetworkManager.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBValues.h"

@interface AMBServiceSelector (Tests)

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot1;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight1;
@property (nonatomic, strong) NSTimer *waitViewTimer;
@property (nonatomic, strong) IBOutlet UILabel * lblURL;
@property (nonatomic, strong) AMBUserUrlNetworkObject *urlNetworkObj;
@property (nonatomic, strong) UILabel * lblCopied;
@property (nonatomic, strong) NSTimer * copiedAnimationTimer;
@property (nonatomic, strong) NSArray *services;

- (void)stockShareWithSocialMediaType:(AMBSocialServiceType)servicetype;
- (void)setUpCloseButton;
- (void)setUpTheme;
- (void)performIdentify;
- (IBAction)clipboardButtonPress:(UIButton *)button;
- (void)confirmCopyAnimation;
- (void)closeButtonPressed:(UIButton *)button;
- (void)hideConfirmCopyAnimation;
- (void)applyImage;
- (void)checkLinkedInToken;
- (void)presentLinkedInShare;
- (void)removeLoadingView;
- (void)sendIdentify;

@end


@interface AMBServiceSelectorUnitTests : XCTestCase <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) AMBServiceSelector * serviceSelector;

@end

@implementation AMBServiceSelectorUnitTests

- (void)setUp {
    [super setUp];
    if (!self.serviceSelector) {
        self.serviceSelector = [[AMBServiceSelector alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma makr - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    id mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
    
    // WHEN
    [[mockSS expect] setUpTheme];
    [[mockSS expect] setUpCloseButton];
    [[mockSS expect] performIdentify];
    [self.serviceSelector viewDidLoad];
    
    // THEN
    [mockSS verify];
}

- (void)testViewWillAppear {
    // GIVEN
    id mockCollectionView = OCMClassMock([UICollectionView class]);
    self.serviceSelector.collectionView = mockCollectionView;
    
    // WHEN
    [self.serviceSelector viewWillAppear:YES];
    
    // THEN
    OCMVerify([mockCollectionView reloadData]);
}

- (void)testViewWillDisappear {
    // GIVEN
    id mockWaitTimer = OCMClassMock([NSTimer class]);
    self.serviceSelector.waitViewTimer = mockWaitTimer;
    
    // WHEN
    [self.serviceSelector viewWillDisappear:YES];
    
    // THEN
    OCMVerify([mockWaitTimer invalidate]);
}


#pragma mark - IBActions Tests

- (void)testClipboardButtonPress {
    // GIVEN
    id mockServiceSelector = [OCMockObject partialMockForObject:self.serviceSelector];
    self.serviceSelector.lblURL = [[UILabel alloc] init];
    self.serviceSelector.lblURL.text = @"test";
    
    // WHEN
    [[mockServiceSelector expect] confirmCopyAnimation];
    [self.serviceSelector clipboardButtonPress:nil];
    
    // THEN
    [mockServiceSelector verify];
}


#pragma mark - Navigation Tests

- (void)testPrepareForContactSegue {
    // GIVEN
    NSString *contactSegueId = @"goToContactSelector";
    self.serviceSelector.urlNetworkObj = [[AMBUserUrlNetworkObject alloc] init];
    self.serviceSelector.urlNetworkObj.url = @"test@test.com";
    self.serviceSelector.urlNetworkObj.short_code = @"TEST";
    
    AMBContactSelector *contactVC = [[AMBContactSelector alloc ]init];
    UIStoryboardSegue *testSB = [[UIStoryboardSegue alloc ] initWithIdentifier:contactSegueId source:self.serviceSelector destination:contactVC];
    
    // WHEN
    [self.serviceSelector prepareForSegue:testSB sender:self.serviceSelector];
    
    // THEN
    XCTAssertEqualObjects(self.serviceSelector.urlNetworkObj.url, contactVC.shortURL);
    XCTAssertEqualObjects(self.serviceSelector.urlNetworkObj.short_code, contactVC.shortCode);
    XCTAssertEqual(self.serviceSelector.urlNetworkObj, contactVC.urlNetworkObject);
}

- (void)testPrepareForLinkedInSegue {
    // GIVEN
    NSString *linkedInSegueid = @"goToAuthorizeLinkedIn";
    AMBAuthorizeLinkedIn *linkedInVC = [[AMBAuthorizeLinkedIn alloc] init];
    UIStoryboardSegue *linkedSB = [[UIStoryboardSegue alloc] initWithIdentifier:linkedInSegueid source:self.serviceSelector destination:linkedInVC];
    
    // WHEN
    [self.serviceSelector prepareForSegue:linkedSB sender:self.serviceSelector];
    
    // THEN
    XCTAssertEqual(self.serviceSelector, (AMBServiceSelector*)linkedInVC.delegate);
}

//- (void)testCloseButtonPressed {
//    // GIVEN
//    UIViewController *mockVC = [[UIViewController alloc] init];
//    [mockVC presentViewController:self.serviceSelector animated:NO completion:nil];
//    id mockPresentingVC = [OCMockObject partialMockForObject:self.serviceSelector.presentingViewController];
//    
//    // WHEN
//    [[mockPresentingVC expect] dismissViewControllerAnimated:YES completion:nil];
//    [self.serviceSelector closeButtonPressed:nil];
//    
//    // THEN
////    [mockPresentingVC dismissViewControllerAnimated:YES completion:nil];
//    [mockPresentingVC verify];
//}


#pragma mark - UI Function Tests

- (void)testConfirmCopyAnimation {
    // GIVEN
    NSString *lblText = @"Copied!";
    
    // WHEN
    [self.serviceSelector confirmCopyAnimation];
    
    // THEN
    XCTAssertEqual(self.serviceSelector.lblCopied.alpha, 1);
    XCTAssertEqualObjects(self.serviceSelector.lblCopied.text, lblText);
}

- (void)testHideConfirmationCopyAnimation {
    // GIVEN
    id mockTimer = OCMClassMock([NSTimer class]);
    self.serviceSelector.copiedAnimationTimer = mockTimer;
    
    // WHEN
    [[mockTimer expect] invalidate];
    [self.serviceSelector hideConfirmCopyAnimation];
    
    // THEN
    [mockTimer verify];
    XCTAssertEqual(self.serviceSelector.lblCopied.alpha, 0);
}

- (void)testSetUpTheme {
    // GIVEN
    NSString *expectedWelcomeString = @"Spread the word";
    NSString *expectedDescriptionString = @"Refer a friend to get rewards";
    NSString *expectedTitleString = @"Refer your friends";
    
    // WHEN
    [self.serviceSelector setUpTheme];
    NSString *welcomeString = [[AMBThemeManager sharedInstance] messageForKey:RAFWelcomeTextMessage];
    NSString *descriptionLblString =[[AMBThemeManager sharedInstance] messageForKey:RAFDescriptionTextMessage];
    NSString *titleString = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    
    // THEN
    XCTAssertEqualObjects(welcomeString, expectedWelcomeString);
    XCTAssertEqualObjects(descriptionLblString, expectedDescriptionString);
    XCTAssertEqualObjects(titleString, expectedTitleString);
}

//- (void)testApplyImage {
//    // GIVEN
//    id mockImageView = OCMClassMock([UIImage class]);
//    UIImageView *mockImage = self.serviceSelector.imgSlot1;
//    self.serviceSelector.imgSlot1 = mockImageView;
////    self.serviceSelector.imgSlot1 = mockImageSlot1;
//    
//    // WHEN
//    [self.serviceSelector applyImage];
//    
//    // THEN
//    ocm
////    XCTAssertNotNil(mockImage.image);
//    XCTAssertEqual(, 70);
//    oc
//}

- (void)testSetUpCloseButton {
    // WHEN
    [self.serviceSelector setUpCloseButton];
    
    // THEN
    XCTAssertNotNil(self.serviceSelector.navigationItem.leftBarButtonItem);
}


#pragma mark - Helper Function Tests

- (void)testStockShareWithSocialMedia {
    // GIVEN
    id mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
    
    // WHEN
    [[mockSS expect] presentViewController:[OCMArg isKindOfClass:[UIViewController class]] animated:YES completion:[OCMArg any]];
    [self.serviceSelector stockShareWithSocialMediaType:AMBSocialServiceTypeFacebook];
    
    // THEN
    [mockSS verify];
}

//- (void)testCheckLinkedInTokenFail {
//    // GIVEN
//    id mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
//    
//    // WHEN
//    XCTestExpectation *expectation = [self expectationWithDescription:@"test"];
//    [[mockSS expect] performSegueWithIdentifier:@"goToAuthorizeLinkedIn" sender:self.serviceSelector];
//    [self.serviceSelector checkLinkedInToken];
//    [expectation fulfill];
//    
//    
//    // THEN
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
//        [mockSS verify];
//    }];
//    
//}

- (void)testPresentLinkedInShare {
    // GIVEN
    id mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
    self.serviceSelector.urlNetworkObj = [[AMBUserUrlNetworkObject alloc] init];
    self.serviceSelector.urlNetworkObj.short_code = @"TEST";
    self.serviceSelector.urlNetworkObj.url = @"test@test.com";
    
    // WHEN
    [[mockSS expect] presentViewController:[OCMArg isKindOfClass:[UIViewController class]] animated:YES completion:nil];
    [self.serviceSelector presentLinkedInShare];
    
    // THEN
    [mockSS verify];
}

- (void)testRemoveLoadingViewSuccess {
    // GIVEN
    id waitViewTimerMock = OCMClassMock([NSTimer class]);
    self.serviceSelector.waitViewTimer = [[NSTimer alloc] init];
    self.serviceSelector.waitViewTimer = waitViewTimerMock;
    self.serviceSelector.campaignID = @"864";
    NSDictionary *urlDict = @{ @"campaign_uid" : @864, @"has_access" : @1, @"is_active" : @1, @"short_code" : @"jHjg", @"subject" : @"Check out Developers!", @"url" : @"http://staging.mbsy.co/jHjg" };
    
    AMBUserUrlNetworkObject *networkUrlObj = [[AMBUserUrlNetworkObject alloc] initWithDictionary:urlDict];

    AMBUserNetworkObject *networkObj = [[AMBUserNetworkObject alloc] init];
    networkObj.email = @"jake@getambassador.com";
    networkObj.first_name = @"Jake";
    networkObj.last_name = @"Dunahee";
    networkObj.uid = @"864";

    [AmbassadorSDK sharedInstance].user = networkObj;
    [AmbassadorSDK sharedInstance].user.uid = @"864";
    [AmbassadorSDK sharedInstance].user.urls = [NSMutableArray arrayWithObject:networkUrlObj];
    
    // WHEN
    [self.serviceSelector removeLoadingView];
    
    // THEN
    XCTAssertNotNil(self.serviceSelector.urlNetworkObj);
    OCMVerify([waitViewTimerMock invalidate]);
}

- (void)testRemoveLoadingViewNoIDMatch {
    // GIVEN
    id waitViewTimerMock = OCMClassMock([NSTimer class]);
    self.serviceSelector.waitViewTimer = [[NSTimer alloc] init];
    self.serviceSelector.waitViewTimer = waitViewTimerMock;
    self.serviceSelector.campaignID = @"200";
    
    NSDictionary *urlDict = @{ @"campaign_uid" : @864, @"has_access" : @1, @"is_active" : @1, @"short_code" : @"jHjg", @"subject" : @"Check out Developers!", @"url" : @"http://staging.mbsy.co/jHjg" };
    
    AMBUserUrlNetworkObject *networkUrlObj = [[AMBUserUrlNetworkObject alloc] initWithDictionary:urlDict];
    
    AMBUserNetworkObject *networkObj = [[AMBUserNetworkObject alloc] init];
    networkObj.email = @"jake@getambassador.com";
    networkObj.first_name = @"Jake";
    networkObj.last_name = @"Dunahee";
    networkObj.uid = @"864";
    
    [AmbassadorSDK sharedInstance].user = networkObj;
    [AmbassadorSDK sharedInstance].user.uid = @"864";
    [AmbassadorSDK sharedInstance].user.urls = [NSMutableArray arrayWithObject:networkUrlObj];
    
    // WHEN
    [self.serviceSelector removeLoadingView];
    
    // THEN
    XCTAssertNil(self.serviceSelector.urlNetworkObj);
    OCMVerify([waitViewTimerMock invalidate]);
}

- (void)testPerformIdentifyWithValidChannel {
    // GIVEN
    id mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
    [AmbassadorSDK sharedInstance].pusherManager = [[AMBPusherManager alloc] init]; // Fakes pusherManager and connection
    [AmbassadorSDK sharedInstance].pusherManager.connectionState = PTPusherConnectionConnected;
    
    NSDictionary *pusherChannelDict = @{ @"channel_name" : @"private-channel@user=gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
                                         @"client_session_uid" : @"gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
                                         @"expires_at" : @"2900-02-02T20:21:23.885" };
    
    [AMBValues setPusherChannelObject:pusherChannelDict];
    
    
    // WHEN
    [[mockSS expect] sendIdentify];
    [self.serviceSelector performIdentify];
    
    // THEN
    [mockSS verify];
}

- (void)testPerformIdentifyWithDisconnectedPusher {
    // GIVEN
    id mockPusherMgr = OCMClassMock([AMBPusherManager class]);
    [AmbassadorSDK sharedInstance].pusherManager = [[AMBPusherManager alloc] init]; // Fakes pusherManager and connection
    [AmbassadorSDK sharedInstance].pusherManager.connectionState = PTPusherConnectionDisconnected;
    [AmbassadorSDK sharedInstance].pusherManager = mockPusherMgr;
    
    NSDictionary *pusherChannelDict = @{ @"channel_name" : @"private-channel@user=gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
                                         @"client_session_uid" : @"gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
                                         @"expires_at" : @"2900-02-02T20:21:23.885" };
    
    [AMBValues setPusherChannelObject:pusherChannelDict];
    
    
    // WHEN
    [[mockPusherMgr expect] resubscribeToExistingChannelWithCompletion:[OCMArg any]];
    [self.serviceSelector performIdentify];
    
    // THEN
    [mockPusherMgr verify];
}

//- (void)testPerformIdentifyWithExpiredChannel {
//    // GIVEN
//    id mockAmbassadorSDK = OCMClassMock([AmbassadorSDK class]);
//    [AMBValues resetHasInstalled];
//    AmbassadorSDK *sdk = [AmbassadorSDK sharedInstance];
//    sdk = mockAmbassadorSDK;
//    NSDictionary *expiredChannelDict = @{ @"channel_name" : @"private-channel@user=gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
//                                         @"client_session_uid" : @"gAAAAABWp9VD55okqsd4attaQEkXkXSDnBDYzcHc6a8p1dSKdMBsqXKDuUGi6UzTXd9G-1jOgNVONVlc4jYVgrsD3CLQmyCx867qFPItiL2PowHpCP0rLG4kyN1qhCwFzANvFCdl2jW4",
//                                         @"expires_at" : @"2000-02-02T20:21:23.885" };
// 
//    [AMBValues setPusherChannelObject:expiredChannelDict];
//    
//    // WHEN
//    [[mockAmbassadorSDK expect] subscribeToPusherWithCompletion:[OCMArg isNotNil]];
//    [self.serviceSelector performIdentify];
//    
//    // THEN
//    [mockAmbassadorSDK verify];
//}

//- (void)testSendIdentify {
//    // GIVEN
//    self.serviceSelector.campaignID = @"206";
//    id mockNetworkMgr = OCMClassMock([AMBNetworkManager class]);
//    AMBNetworkManager *networkmanager = [AMBNetworkManager sharedInstance];
//    networkmanager = mockNetworkMgr;
//    
//    // WHEN
//    [[mockNetworkMgr expect] sendIdentifyForCampaign:self.serviceSelector.campaignID shouldEnroll:YES success:[OCMArg isNotNil] failure:[OCMArg isNotNil]];
//    [self.serviceSelector sendIdentify];
//    
//    // THEN
//    [mockNetworkMgr verify];
//}

@end
