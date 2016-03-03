//
//  AMBLinkCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBLinkCell.h"

@interface AMBLinkCell (Tests)

@property (nonatomic, strong) IBOutlet UIButton * btnLinkName;
@property (nonatomic) NSInteger rowNumber;

- (IBAction)buttonPressed:(id)sender;

@end


@interface AMBLinkCellTests : XCTestCase

@property (nonatomic, strong) AMBLinkCell * linkCell;
@property (nonatomic) id mockLinkCell;

@end

@implementation AMBLinkCellTests

- (void)setUp {
    [super setUp];
    
    if (!self.linkCell) {
        self.linkCell = [[AMBLinkCell alloc] init];
    }
    
    self.mockLinkCell = [OCMockObject partialMockForObject:self.linkCell];
}

- (void)tearDown {
    [self.mockLinkCell stopMocking];
    [super tearDown];
}

- (void)testSetUpCell {
    // GIVEN
    self.linkCell.btnLinkName = [[UIButton alloc] init];
    NSString *linkname = @"Test";
    UIColor *linkColor = [UIColor blackColor];
    NSInteger rowNum = 1;
    
    // WHEN
    [self.linkCell setupCellWithLinkName:linkname tintColor:linkColor rowNum:rowNum];
    
    // THEN
    XCTAssertEqualObjects(self.linkCell.btnLinkName.tintColor, linkColor);
    XCTAssertEqualObjects(self.linkCell.btnLinkName.titleLabel.text, linkname);
    XCTAssertEqual(self.linkCell.rowNumber, rowNum);
}

- (void)testButtonPressed {
    // GIVEN
    self.linkCell.rowNumber = 1;
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBLinkCellDelegate)];
    [[[mockDelegate expect] andDo:nil] buttonPressedAtIndex:1];
    self.linkCell.delegate = mockDelegate;
    
    // WHEN
    [self.linkCell buttonPressed:nil];
    
    // THEN
    [mockDelegate verify];
    [mockDelegate stopMocking];
}


@end
