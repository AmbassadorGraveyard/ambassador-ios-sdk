//
//  AMBWelcomeScreenTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBWelcomeScreenViewController.h"
#import "AMBLinkCell.h"

@interface AMBWelcomeScreenViewController (Test) <UICollectionViewDataSource, AMBLinkCellDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView * linkCollectionView;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) NSArray * linkArray;
@property (nonatomic, strong) NSString * referrerName;

- (void)setTheme;
- (void)setupCollectionView;
- (NSString*)getCorrectString:(NSString*)string;
- (BOOL)customContainsString:(NSString*)string subString:(NSString*)subString;
- (IBAction)closeTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
- (BOOL)nameIsMidSentence:(NSString*)text charSpot:(NSUInteger)spot;
- (BOOL)usingReferrerDefaultValue;

@end


@interface AMBWelcomeScreenTests : XCTestCase

@property (nonatomic, strong) AMBWelcomeScreenViewController * welcomeVC;
@property (nonatomic) id mockWelcomeVC;

@end


@implementation AMBWelcomeScreenTests

- (void)setUp {
    [super setUp];
    if (!self.welcomeVC) {
        self.welcomeVC = [[AMBWelcomeScreenViewController alloc] init];
    }
    
    self.mockWelcomeVC = [OCMockObject partialMockForObject:self.welcomeVC];
}

- (void)tearDown {
    [self.mockWelcomeVC stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    [[[self.mockWelcomeVC expect] andDo:nil] setTheme];
    [[[self.mockWelcomeVC expect] andDo:nil] setupCollectionView];
    
    // WHEN
    [self.welcomeVC viewDidLoad];
    
    // THEN
    [self.mockWelcomeVC verify];
}

- (void)testWillAnimateRotation {
    // GIVEN
    id mockCollectionView = [OCMockObject mockForClass:[UICollectionView class]];
    self.welcomeVC.linkCollectionView = mockCollectionView;
    
    [[[mockCollectionView expect] andDo:nil] reloadData];
    
    // WHEN
    [self.welcomeVC willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0.2];
    
    // THEN
    [mockCollectionView verify];
    [mockCollectionView stopMocking];
}


#pragma mark - IBAction Tests

- (void)testCloseTapped {
    // GIVEN
    [[[self.mockWelcomeVC expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.welcomeVC closeTapped:nil];
    
    // THEN
    [self.mockWelcomeVC verify];
}

- (void)testActionButtonTapped {
    // GIVEN
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBWelcomeScreenDelegate)];
    [[[mockDelegate expect] andDo:nil] welcomeScreenActionButtonPressed:[OCMArg any]];
    self.welcomeVC.delegate = mockDelegate;
    
    // WHEN
    [self.welcomeVC actionButtonTapped:nil];
    
    // THEN
    [mockDelegate verify];
    [mockDelegate stopMocking];
}


#pragma mark - CollectionView DataSource Tests

- (void)testNumberOfItems {
    // GIVEN
    self.welcomeVC.linkArray = @[@"Value 1", @"Value 2"];
    
    // WHEN
    NSInteger actualCount = [self.welcomeVC collectionView:self.welcomeVC.linkCollectionView numberOfItemsInSection:0];
    
    // THEN
    XCTAssertEqual(self.welcomeVC.linkArray.count, actualCount);
}


#pragma mark - AMBLinkCell Delegate Tests

- (void)testButtonPressedAtIndex {
    // GIVEN
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBWelcomeScreenDelegate)];
    [[[mockDelegate expect] andDo:nil] welcomeScreenLinkPressedAtIndex:1];
    self.welcomeVC.delegate = mockDelegate;
    
    // WHEN
    [self.welcomeVC buttonPressedAtIndex:1];
    
    // THEN
    [mockDelegate verify];
    [mockDelegate stopMocking];
}


#pragma mark - UI Function Tests 

- (void)testSetTheme {
    // GIVEN
    id mockButton = [OCMockObject mockForClass:[UIButton class]];
    self.welcomeVC.btnAction = mockButton;
    [[[mockButton expect] andDo:nil] setTitle:[OCMArg any] forState:UIControlStateNormal];
    [[[mockButton expect] andDo:nil] setBackgroundColor:[OCMArg any]];
    
    AMBWelcomeScreenParameters *params = [[AMBWelcomeScreenParameters alloc] init];
    params.actionButtonTitle = @"Test";
    
    self.welcomeVC.parameters = params;
    
    // WHEN
    [self.welcomeVC setTheme];
    
    // THEN
    [mockButton verify];
    [mockButton stopMocking];
}

- (void)testSetupCollectionView {
    // GIVEN
    id mockCollectionView = [OCMockObject mockForClass:[UICollectionView class]];
    self.welcomeVC.linkCollectionView =  mockCollectionView;
    [[[mockCollectionView expect] andDo:nil] setScrollEnabled:YES];
    [[[mockCollectionView expect] andDo:nil] setCollectionViewLayout:[OCMArg any]];
    
    self.welcomeVC.linkArray = @[@"Test", @"test2", @"test3"];
    
    // WHEN
    [self.welcomeVC setupCollectionView];
    
    // THEN
    [mockCollectionView verify];
}


#pragma mark - Helper Function Tests 

- (void)testGetCorrectString {
    // GIVEN
    self.welcomeVC.referrerName = @"John Test Doe";
    NSString *mockPassedString = @"{{ name }} testing 123";
    NSString *expectedString = @"John Test Doe testing 123";
    
    // WHEN
    NSString *actualString = [self.welcomeVC getCorrectString:mockPassedString];
    
    // THEN
    XCTAssertEqualObjects(expectedString, actualString);
}

- (void)testCustomContainsString {
    // GIVEN
    NSString *subString1 = @"test";
    NSString *subString2 = @"hello";
    NSString *stringCheck = @"This is a test";
    
    // WHEN
    BOOL contains = [self.welcomeVC customContainsString:stringCheck subString:subString1];
    BOOL doesntContain = [self.welcomeVC customContainsString:stringCheck subString:subString2];
    
    // THEN
    XCTAssertTrue(contains);
    XCTAssertFalse(doesntContain);
}

- (void)testNameIsMidSentence {
    // GIVEN
    NSString *fullString = @"Hello there. This is a test.";
    NSString *stringCheckOne = @"there";
    NSString *stringCheckTwo = @"This";
    
    NSRange rangeOne = [fullString rangeOfString:stringCheckOne];
    NSRange rangeTwo = [fullString rangeOfString:stringCheckTwo];
    
    // WHEN
    BOOL test1 = [self.welcomeVC nameIsMidSentence:fullString charSpot:rangeOne.location];
    BOOL test2 = [self.welcomeVC nameIsMidSentence:fullString charSpot:rangeTwo.location];
    
    // THEN
    XCTAssertTrue(test1);
    XCTAssertFalse(test2);
}

- (void)testUsingReferrerDefaultValue {
    // WHEN
    self.welcomeVC.referrerName = @"Test Name";
    BOOL test1 = [self.welcomeVC usingReferrerDefaultValue];
    
    self.welcomeVC.referrerName = @"An ambassador of Test company";
    BOOL test2 = [self.welcomeVC usingReferrerDefaultValue];
    
    // THEN
    XCTAssertFalse(test1);
    XCTAssertTrue(test2);
}

@end
