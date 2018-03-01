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
#import "AMBErrors.h"
#import "AMBShareServiceCell.h"
#import "AMBLinkedInShare.h"
#import "UIColor+AMBColorValues.h"
#import "AMBUtilities.h"

@interface AMBServiceSelector (Tests) <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AMBShareServiceDelegate, AMBUtilitiesDelegate>

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
@property (nonatomic) BOOL attemptedAutoEnroll;

- (void)stockShareWithSocialMediaType:(AMBSocialServiceType)servicetype;
- (void)setUpCloseButton;
- (void)setUpTheme;
- (void)performIdentityCheck;
- (IBAction)clipboardButtonPress:(UIButton *)button;
- (void)confirmCopyAnimation;
- (void)closeButtonPressed:(UIButton *)button;
- (void)hideConfirmCopyAnimation;
- (void)applyImage;
- (void)checkLinkedInToken;
- (void)presentLinkedInShare;
- (void)removeLoadingView;
- (void)sendIdentify;
- (void)attemptAutoEnroll;
- (BOOL)isFacebookAppInstalled;
- (BOOL)isTwitterAppInstalled;

@end


@interface AMBServiceSelectorUnitTests : XCTestCase

@property (nonatomic, strong) AMBServiceSelector * serviceSelector;
@property (nonatomic) id mockNetworkMgr;
@property (nonatomic) id mockSS;

@end

@implementation AMBServiceSelectorUnitTests

- (void)setUp {
    [super setUp];
    if (!self.serviceSelector) {
        self.serviceSelector = [[AMBServiceSelector alloc] init];
        [[AMBThemeManager sharedInstance] createDicFromPlist:@"GenericTheme"];
    }
    
    self.mockSS = [OCMockObject partialMockForObject:self.serviceSelector];
    self.mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
}

- (void)tearDown {
    [self.mockNetworkMgr stopMocking];
    [self.mockSS stopMocking];
    [super tearDown];
}


#pragma makr - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    [[self.mockSS expect] setUpTheme];
    [[self.mockSS expect] setUpCloseButton];
    [[self.mockSS expect] performIdentityCheck];
    
    // WHEN
    [self.serviceSelector viewDidLoad];
    
    // THEN
    [self.mockSS verify];
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
    self.serviceSelector.lblURL = [[UILabel alloc] init];
    self.serviceSelector.lblURL.text = @"test";
    [[self.mockSS expect] confirmCopyAnimation];
    
    // WHEN
    [self.serviceSelector clipboardButtonPress:nil];
    
    // THEN
    [self.mockSS verify];
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

- (void)testCloseButtonPressed {
    // GIVEN
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    [[mockPresentingVC expect] dismissViewControllerAnimated:YES completion:nil];
    [[[self.mockSS expect] andReturn:mockPresentingVC] presentingViewController];
    
    // WHEN
    [self.serviceSelector closeButtonPressed:nil];
    
    // THEN
    [mockPresentingVC verify];
}


#pragma mark - CollectionView Tests

- (void)testCollectionViewNumOfItems {
    // GIVEN
    self.serviceSelector.services = [[AMBThemeManager sharedInstance] customSocialGridArray];
    
    // WHEN
    NSInteger numOfCells = [self.serviceSelector collectionView:self.serviceSelector.collectionView numberOfItemsInSection:0];
    
    // THEN
    XCTAssertEqual(numOfCells, [self.serviceSelector.services count]);
}

- (void)testCollectionViewCell {
    // GIVEN
    id mockCell = [OCMockObject mockForClass:[AMBShareServiceCell class]];
    [[mockCell expect] setUpCellWithCellType:(int)[OCMArg any]];
    
    // WHEN
    mockCell = [self.serviceSelector collectionView:self.serviceSelector.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // THEN
    [mockCell verify];
}

- (void)testDidSelectItemCollectionView {
    // GIVEN
    [[self.mockSS expect] stockShareWithSocialMediaType:AMBSocialServiceTypeFacebook];
    [[[self.mockSS expect] andReturnValue:OCMOCK_VALUE(YES)] isFacebookAppInstalled];
    
    // WHEN
    [self.serviceSelector collectionView:self.serviceSelector.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    // THEN
    [self.mockSS verify];
}

- (void)testDidHighlightItem {
    // GIVEN
    id mockColor = [OCMockObject mockForClass:[UIColor class]];
    [[mockColor expect] cellSelectionGray];
    
    // WHEN
    [self.serviceSelector collectionView:self.serviceSelector.collectionView didHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    // THEN
    [mockColor verify];
}

- (void)testDidUnhighlightItem {
    // GIVEN
    id mockThemeMgr = [OCMockObject partialMockForObject:[AMBThemeManager sharedInstance]];
    [[mockThemeMgr expect] colorForKey:RAFBackgroundColor];
    
    // WHEN
    [self.serviceSelector collectionView:self.serviceSelector.collectionView didUnhighlightItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    // THEN
    [mockThemeMgr verify];
}

#pragma mark - ShareServiceDelegate Tests

- (void)testNetworkError {
    // GIVEN
    NSString *errorString = @"There was an error";
    id mockError = [OCMockObject mockForClass:[AMBErrors class]];
    [[[mockError expect] andDo:nil] errorLinkedInShareForVC:self.serviceSelector withMessage:errorString];
    
    // WHEN
    [self.serviceSelector networkError:@"Title" message:errorString];
    
    // THEN
    [mockError verify];
}

- (void)testUserDidPost {
    // GIVEN
    [[self.mockNetworkMgr expect] sendShareTrackForServiceType:AMBSocialServiceTypeLinkedIn contactList:nil success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.serviceSelector userDidPostFromService:@"LinkedIn"];
    
    // THEN
    [self.mockNetworkMgr verify];
}

- (void)testUserMustReauthenticate {
    // GIVEN
    id mockError = [OCMockObject mockForClass:[AMBErrors class]];
    [[[mockError expect] andDo:nil] errorLinkedInReauthForVC:self.serviceSelector];
    
    // WHEN
    [self.serviceSelector userMustReauthenticate];
    
    // THEN
    [mockError verify];
}


#pragma mark - Custom Alert Delegate

- (void)testOkayButtonClicked {
    // GIVEN
    NSString *uniqueID = @"linkedInAuth";
    [[[self.mockSS expect] andDo:nil] performSegueWithIdentifier:[OCMArg any] sender:self.serviceSelector];
    
    // WHEN
    [self.serviceSelector okayButtonClickedForUniqueID:uniqueID];
    
    // THEN
    [self.mockSS verify];
}

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
    [[mockTimer expect] invalidate];
    
    // WHEN
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

- (void)testApplyImage {
    // GIVEN
    self.serviceSelector.imgSlot1 = [[UIImageView alloc] init];
    self.serviceSelector.imgSlotHeight1 = [[NSLayoutConstraint alloc] init];
    
    // WHEN
    [self.serviceSelector applyImage];
    
    // THEN
    XCTAssertEqual(70, self.serviceSelector.imgSlotHeight1.constant);
}

- (void)testSetUpCloseButton {
    // WHEN
    [self.serviceSelector setUpCloseButton];
    
    // THEN
    XCTAssertNotNil(self.serviceSelector.navigationItem.leftBarButtonItem);
}


#pragma mark - Helper Function Tests

- (void)testStockShareWithSocialMedia {
    // GIVEN
    [[[self.mockSS expect] andDo:nil] presentViewController:[OCMArg any] animated:YES completion:[OCMArg any]];
    
    // WHEN
    [self.serviceSelector stockShareWithSocialMediaType:AMBSocialServiceTypeFacebook];
    
    // THEN
    [self.mockSS verify];
}

- (void)testCheckLinkedInTokenFail {
    // GIVEN
    [AMBValues setLinkedInAccessToken:@"fakeToken"];
    [[[self.mockSS expect] andDo:nil] presentLinkedInShare];
    
    // WHEN
    [self.serviceSelector checkLinkedInToken];
    
    // THEN
    [self.mockSS verify];
}

- (void)testPresentLinkedInShare {
    // GIVEN
    self.serviceSelector.urlNetworkObj = [[AMBUserUrlNetworkObject alloc] init];
    self.serviceSelector.urlNetworkObj.short_code = @"TEST";
    self.serviceSelector.urlNetworkObj.url = @"test@test.com";
    [[self.mockSS expect] presentViewController:[OCMArg isKindOfClass:[UIViewController class]] animated:YES completion:nil];
    
    // WHEN
    [self.serviceSelector presentLinkedInShare];
    
    // THEN
    [self.mockSS verify];
}

- (void)testRemoveLoadingViewSuccess {
    // GIVEN
    id waitViewTimerMock = OCMClassMock([NSTimer class]);
    self.serviceSelector.waitViewTimer = waitViewTimerMock;
    self.serviceSelector.campaignID = @"864";
    NSDictionary *urlDict = @{ @"campaign_uid" : @864, @"has_access" : @1, @"is_active" : @1, @"short_code" : @"jHjg", @"subject" : @"Check out Developers!", @"url" : @"http://staging.mbsy.co/jHjg" };
    
    AMBUserUrlNetworkObject *networkUrlObj = [[AMBUserUrlNetworkObject alloc] initWithDictionary:urlDict];

    AMBUserNetworkObject *networkObj = [[AMBUserNetworkObject alloc] init];
    networkObj.email = @"jake@getambassador.com";
    networkObj.first_name = @"Jake";
    networkObj.last_name = @"Dunahee";
    networkObj.uid = @"864";
    networkObj.urls = [NSMutableArray arrayWithObject:networkUrlObj];

    [AMBValues setUserCampaignList:networkObj];
    
    // WHEN
    [self.serviceSelector removeLoadingView];
    
    // THEN
    XCTAssertNotNil(self.serviceSelector.urlNetworkObj);
    OCMVerify([waitViewTimerMock invalidate]);
}

- (void)testRemoveLoadingViewNoIDMatch {
    // GIVEN
    id waitViewTimerMock = [OCMockObject mockForClass:[NSTimer class]];
    [[[waitViewTimerMock expect] andDo:nil] invalidate];
    
    id mockError = [OCMockObject mockForClass:[AMBErrors class]];
    
    OCMStub(ClassMethod([mockError errorAlertNoMatchingCampaignIdsForVC:[OCMArg any]])).andDo(nil);
    
    self.serviceSelector.waitViewTimer = waitViewTimerMock;
    self.serviceSelector.campaignID = @"200";
    self.serviceSelector.attemptedAutoEnroll = YES;
    
    NSDictionary *urlDict = @{ @"campaign_uid" : @864, @"has_access" : @1, @"is_active" : @1, @"short_code" : @"jHjg", @"subject" : @"Check out Developers!", @"url" : @"http://staging.mbsy.co/jHjg" };
    
    AMBUserUrlNetworkObject *networkUrlObj = [[AMBUserUrlNetworkObject alloc] initWithDictionary:urlDict];
    
    AMBUserNetworkObject *networkObj = [[AMBUserNetworkObject alloc] init];
    networkObj.email = @"jake@getambassador.com";
    networkObj.first_name = @"Jake";
    networkObj.last_name = @"Dunahee";
    networkObj.uid = @"864";
    networkObj.urls = [NSMutableArray arrayWithObject:networkUrlObj];
    
    [AMBValues setUserCampaignList:networkObj];
    
    // WHEN
    [self.serviceSelector removeLoadingView];
    
    // THEN
    XCTAssertNil(self.serviceSelector.urlNetworkObj);
    [waitViewTimerMock verify];
    
    [waitViewTimerMock stopMocking];
}

- (void)testSendIdentify {
    // GIVEN
    self.serviceSelector.campaignID = @"206";
    [[self.mockNetworkMgr expect] sendIdentifyForCampaign:self.serviceSelector.campaignID shouldEnroll:YES success:[OCMArg isNotNil] failure:[OCMArg isNotNil]];
    
    // WHEN
    [self.serviceSelector sendIdentify];
    
    // THEN
    [self.mockNetworkMgr verify];
}

#pragma mark - Block Tests 

- (void)testShareTrackCompletion {
    // GIVEN
    [[[self.mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)() = nil;
        [invocation getArgument:&success atIndex:4];
        success(@{@"key1":@"Test"});
    }] sendShareTrackForServiceType:AMBSocialServiceTypeLinkedIn contactList:nil success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.serviceSelector userDidPostFromService:@"LinkedIn"];
    
    // THEN
    [self.mockNetworkMgr verify];
}

- (void)testShareTrackFailure {
    // GIVEN
    [[[self.mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^failure)() = nil;
        [invocation getArgument:&failure atIndex:5];
        failure(@"ERROR");
    }] sendShareTrackForServiceType:AMBSocialServiceTypeLinkedIn contactList:nil success:[OCMArg any] failure:[OCMArg invokeBlock]];
    
    // WHEN
    [self.serviceSelector userDidPostFromService:@"LinkedIn"];
    
    // THEN
    [self.mockNetworkMgr verify];
}

- (void)testSendIdentifyCompletion {
    // GIVEN
    [[[self.mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)() = nil;
        [invocation getArgument:&success atIndex:5];
        success(@{@"key1":@"Test"});
    }] sendIdentifyForCampaign:[OCMArg any] shouldEnroll:YES success:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    // WHEN
    [self.serviceSelector sendIdentify];
    
    // THEN
    [self.mockNetworkMgr verify];
}

- (void)testSendIdentifyFailure {
    // GIVEN
    [[[self.mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^failure)() = nil;
        [invocation getArgument:&failure atIndex:5];
        failure(@"ERROR");
    }] sendIdentifyForCampaign:[OCMArg any] shouldEnroll:YES success:[OCMArg any] failure:[OCMArg invokeBlock]];
    
    // WHEN
    [self.serviceSelector sendIdentify];
    
    // THEN
    [self.mockNetworkMgr verify];
}

- (void)testAttemptAutoEnroll {
    // GIVEN
    id mockAmbassadorSDK = [OCMockObject partialMockForObject:[AmbassadorSDK sharedInstance]];
    [[[mockAmbassadorSDK expect] andDo:nil] subscribeToPusherWithSuccess:[OCMArg invokeBlock]];
    
    [[[self.mockSS expect] andDo:nil] sendIdentify];
    
    // WHEN
    [self.serviceSelector attemptAutoEnroll];
    
    // THEN
    XCTAssertTrue(self.serviceSelector.attemptedAutoEnroll);
    [mockAmbassadorSDK verify];
    [self.mockSS verify];
    
    [mockAmbassadorSDK stopMocking];
}

- (void)testIsFacebookAppInstalled {
    // GIVEN
    id mockUIApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockUIApplication stub] andReturn:mockUIApplication] sharedApplication];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fbapi://"]];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fb-messenger-api://"]];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fbauth2://"]];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fbshareextension://"]];

    // WHEN
    BOOL installed = [self.serviceSelector isFacebookAppInstalled];

    // THEN
    XCTAssertFalse(installed);
    [mockUIApplication verify];

    // GIVEN
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fbapi://"]];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"fb-messenger-api://"]];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(YES)] canOpenURL:[NSURL URLWithString:@"fbauth2://"]];

    // WHEN
    installed = [self.serviceSelector isFacebookAppInstalled];

    // THEN
    XCTAssertTrue(installed);
    [mockUIApplication verify];
    [mockUIApplication stopMocking];
}

- (void)testIsTwitterAppInstalled {
    // GIVEN
    id mockUIApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockUIApplication stub] andReturn:mockUIApplication] sharedApplication];
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(NO)] canOpenURL:[NSURL URLWithString:@"twitter://"]];

    // WHEN
    BOOL installed = [self.serviceSelector isTwitterAppInstalled];

    // THEN
    XCTAssertFalse(installed);
    [mockUIApplication verify];

    // GIVEN
    [[[mockUIApplication expect] andReturnValue:OCMOCK_VALUE(YES)] canOpenURL:[NSURL URLWithString:@"twitter://"]];

    // WHEN
    installed = [self.serviceSelector isTwitterAppInstalled];

    // THEN
    XCTAssertTrue(installed);
    [mockUIApplication verify];
    [mockUIApplication stopMocking];
}

@end
