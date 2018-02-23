//
//  AMBContactCellUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/8/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBContactCell.h"
#import "UIColor+AMBColorValues.h"

@interface AMBContactCell (Test)

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * checkmarkConstraint;
@property (nonatomic, weak) IBOutlet UIImageView * checkmarkView;
@property (nonatomic, weak) IBOutlet UIImageView * avatarImage;

- (void)setCellSelectionColor;
- (void)longPressTriggered:(UILongPressGestureRecognizer*)sender;

@end


@interface AMBContactCellUnitTests : XCTestCase

@property (nonatomic, strong) AMBContactCell * contactCell;
@property (nonatomic) id mockCell;

@end

@implementation AMBContactCellUnitTests

- (void)setUp {
    [super setUp];
    if (!self.contactCell) {
        self.contactCell = [[AMBContactCell alloc] init];
    }
    
    self.mockCell = [OCMockObject partialMockForObject:self.contactCell];
}

- (void)tearDown {
    [self.mockCell stopMocking];
    [super tearDown];
}

- (void)testSetUpCell {
    // GIVEN
    AMBContact *contact = [[AMBContact alloc] init];
    contact.firstName = @"Test`";
    contact.contactImage = nil;
    
    // WHEN
    [self.contactCell setUpCellWithContact:contact isSelected:NO];
    
    // THEN
    XCTAssertFalse(self.contactCell.avatarImage.hidden);
}


#pragma mark - UI Functions Tests

- (void)testAnimateCheckMarkIn {
    // GIVEN
    id mockConstraint = [OCMockObject mockForClass:[NSLayoutConstraint class]];
    [[[mockConstraint expect] andDo:nil] setConstant:16];
    [(NSLayoutConstraint*)[[mockConstraint expect] andReturnValue:OCMOCK_VALUE(16)] constant];
    
    self.contactCell.checkmarkConstraint = mockConstraint;
    NSInteger expectedConstraintSize = 16;
    
    // WHEN
    [self.contactCell animateCheckmarkIn];
    
    // THEN
    XCTAssertEqual(expectedConstraintSize, self.contactCell.checkmarkConstraint.constant);
    [mockConstraint stopMocking];
}

- (void)testAnimateCheckMarkOut {
    // GIVEN
    id mockConstraint = [OCMockObject mockForClass:[NSLayoutConstraint class]];
    [[[mockConstraint expect] andDo:nil] setConstant:-50];
    [(NSLayoutConstraint*)[[mockConstraint expect] andReturnValue:OCMOCK_VALUE(-50)] constant];
    
    id mockCheckmark = [OCMockObject mockForClass:[UIImageView class]];
    [[[mockCheckmark expect] andReturnValue:OCMOCK_VALUE(CGRectMake(0, 0, 50, 0))] frame];
    self.contactCell.checkmarkView = mockCheckmark;
    
    self.contactCell.checkmarkConstraint = mockConstraint;
    NSInteger expectedConstraintSize = -50;
    
    // WHEN
    [self.contactCell animateCheckmarkOut];
    
    // THEN
    XCTAssertEqual(expectedConstraintSize, self.contactCell.checkmarkConstraint.constant);
    [mockConstraint stopMocking];
}

- (void)testSetCellSelectionColor {
    // WHEN
    [self.contactCell setCellSelectionColor];
    
    // THEN
    XCTAssertEqualObjects(self.contactCell.selectedBackgroundView.backgroundColor, [UIColor cellSelectionGray]);
}

@end
