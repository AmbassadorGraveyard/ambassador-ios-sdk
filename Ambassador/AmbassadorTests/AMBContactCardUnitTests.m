//
//  AMBContactCardUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/8/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBContactCard.h"
#import "AMBUtilities.h"

@interface AMBContactCard (Test) <UITableViewDataSource, UITableViewDelegate>

- (void)setUpCard;
- (void)resizeMasterView;
- (IBAction)buttonCloseTapped:(id)sender;

@property (nonatomic, strong) NSMutableArray * valueArray;
@property (nonatomic, strong) IBOutlet UITableView * infoTableView;
@property (nonatomic, strong) IBOutlet UIImageView * ivAvatarImage;

@end


@interface AMBContactCardUnitTests : XCTestCase

@property (nonatomic, strong) AMBContactCard * contactCard;
@property (nonatomic) id mockContactCard;

@end

@implementation AMBContactCardUnitTests

- (void)setUp {
    [super setUp];
    if (!self.contactCard) {
        self.contactCard = [[AMBContactCard alloc] init];
    }
    
    self.mockContactCard = [OCMockObject partialMockForObject:self.contactCard];
}

- (void)tearDown {
    [self.mockContactCard stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    [[[self.mockContactCard expect] andDo:nil] setUpCard];
    
    // WHEN
    [self.contactCard viewDidLoad];
    
    // THEN
    [self.mockContactCard verify];
    XCTAssertNotNil(self.contactCard.valueArray);
}

- (void)testViewwillAppear {
    // GIVEN
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] addFadeToView:[OCMArg any]];
    
    // WHEN
    [self.contactCard viewWillAppear:YES];
    
    // THEN
    [mockUtils verify];
    [mockUtils stopMocking];
}

- (void)testViewWillDisappear {
    // GIVEN
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] removeFadeFromView];
    
    // WHEN
    [self.contactCard viewWillDisappear:YES];
    
    // THEN
    [mockUtils verify];
    [mockUtils stopMocking];
}

- (void)testViewDidLayoutSubview {
    // GIVEN
    [[[self.mockContactCard expect] andDo:nil] resizeMasterView];
    
    // WHEN
    [self.contactCard viewDidLayoutSubviews];
    
    // THEN
    [self.mockContactCard verify];
}

- (void)testWillAnimateRotation {
    // GIVEN
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] rotateFadeForView:[OCMArg any]];
    
    [[[self.mockContactCard expect] andDo:nil] resizeMasterView];
    
    // WHEN
    [self.contactCard willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:2.0];
    
    // THEN
    [self.mockContactCard verify];
    [mockUtils verify];
    [mockUtils stopMocking];
}


#pragma mark - IBAction Tests

- (void)testButtonCloseTap {
    // GIVEN
    [[[self.mockContactCard expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.contactCard buttonCloseTapped:nil];
    
    // THEN
    [self.mockContactCard verify];
}


#pragma mark - UITableView Delegate Tests

- (void)testNumOfRows {
    // GIVEN
    id mockArray = [OCMockObject mockForClass:[NSArray class]];
    [[[mockArray expect] andReturnValue:OCMOCK_VALUE(5)] count];
    self.contactCard.valueArray = mockArray;
    
    // WHEN
    NSInteger numOfRows = [self.contactCard tableView:self.contactCard.infoTableView numberOfRowsInSection:0];
    
    // THEN
    XCTAssertEqual(numOfRows, 5);
}

- (void)testHeightForRow {
    // GIVEN
    CGFloat expected = 35;
    
    // WHEN
    CGFloat returned = [self.contactCard tableView:self.contactCard.infoTableView heightForRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    // THEN
    XCTAssertEqual(expected, returned);
}


#pragma mark - UI Function Tests

- (void)testSetUpCard {
    // GIVEN
    AMBContact *contact = [[AMBContact alloc] init];
    contact.firstName = @"Test";
    contact.contactImage = nil;
    
    self.contactCard.contact = contact;
    
    // WHEN
    [self.contactCard setUpCard];
    
    // THEN
    XCTAssertFalse(self.contactCard.ivAvatarImage.hidden);
}

@end
