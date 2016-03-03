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

@property (nonatomic, strong) IBOutlet NSLayoutConstraint * masterViewCenter;
@property (nonatomic, strong) IBOutlet UICollectionView * linkCollectionView;
@property (nonatomic, strong) NSArray * linkArray;
@property (nonatomic, strong) NSString * referrerName;

- (void)setTheme;
- (void)setupCollectionView;
- (NSString*)getCorrectString:(NSString*)string;
- (BOOL)customContainsString:(NSString*)string subString:(NSString*)subString;
- (IBAction)closeTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;

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

- (void)testViewDidLayoutSubviews {
    // GIVEN
    self.welcomeVC.masterViewCenter = [[NSLayoutConstraint alloc] init];
    self.welcomeVC.masterViewCenter.constant = 1;
    
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[mockView expect] andDo:nil] animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:[OCMArg any] completion:nil];
    
    // WHEN
    [self.welcomeVC viewDidLayoutSubviews];
    
    // THEN
    [mockView verify];
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

@end
