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

@interface AMBContactCell (Test)

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * checkmarkConstraint;
@property (nonatomic, weak) IBOutlet UIImageView * checkmarkView;

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
    
    // WHEN
    
    // THEN
}


#pragma mark - Helper Function Tests

//- (void)testLongPressTriggered {
//    // GIVEN
//    id mockGesture = [OCMockObject mockForClass:[UILongPressGestureRecognizer class]];
//    [[[mockGesture expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateBegan)] state];
//    
//    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBContactCellDelegate)];
//    [[[mockDelegate expect] andDo:nil] longPressTriggeredForContact:[OCMArg any]];
//    
//    // WHEN
//    [self.contactCell longPressTriggered:mockGesture];
//    
//    // THEN
//    [mockGesture verify];
//    [mockDelegate verify];
//}


#pragma mark - UI Functions Tests

- (void)testAnimateCheckMarkIn {
    // GIVEN
    id mockConstraint = [OCMockObject mockForClass:[NSLayoutConstraint class]];
    [[[mockConstraint expect] andDo:nil] setConstant:16];
    [[[mockConstraint expect] andReturnValue:OCMOCK_VALUE(16)] constant];
    
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
    [[[mockConstraint expect] andReturnValue:OCMOCK_VALUE(-50)] constant];
    
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
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[mockView expect] andReturnValue:mockView] alloc];
    [[[mockView expect] andDo:nil] setBackgroundColor:[OCMArg any]];
    
    // WHEN
    [self.contactCell setCellSelectionColor];
    
    
    // THEN
    [mockView verify];
    XCTAssertEqual(self.contactCell.selectedBackgroundView, mockView);
}

@end
