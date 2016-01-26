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

- (void)setUpCloseButton;
- (void)setUpTheme;
- (void)setUpCloseButton;
- (void)performIdentify;
- (IBAction)clipboardButtonPress:(UIButton *)button;
- (void)confirmCopyAnimation;
- (void)closeButtonPressed:(UIButton *)button;
- (void)hideConfirmCopyAnimation;
- (void)applyImage;

@end


@interface AMBServiceSelectorUnitTests : XCTestCase

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

@end
