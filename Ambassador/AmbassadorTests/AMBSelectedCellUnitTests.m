//
//  AMBSelectedCellUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/8/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBContact.h"
#import "AMBSelectedCell.h"

@interface AMBSelectedCell (Test)

- (IBAction)removeButtonPressed:(UIButton *)sender;

@end


@interface AMBSelectedCellUnitTests : XCTestCase

@property (nonatomic, strong) AMBSelectedCell * selectedCell;

@end


@implementation AMBSelectedCellUnitTests

- (void)setUp {
    [super setUp];
    if (!self.selectedCell) {
        self.selectedCell = [[AMBSelectedCell alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetUpCell {
    // GIVEN
    self.selectedCell.name = [[UILabel alloc] init];
    
    AMBContact *contact = [[AMBContact alloc] init];
    contact.firstName = @"Test";
    contact.value = @"555-555-5555";
    
    // WHEN
    [self.selectedCell setUpCellWithContact:contact];
    
    // THEN
    XCTAssertEqualObjects(self.selectedCell.name.text, @"Test - 555-555-5555");
}

- (void)testRemoveButtonPressed {
    // GIVEN
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBSelectedCellDelegate)];
    [[[mockDelegate expect] andDo:nil] removeButtonTappedForContact:[OCMArg any]];
    self.selectedCell.delegate = mockDelegate;
    
    // WHEN
    [self.selectedCell removeButtonPressed:nil];
    
    // THEN
    [mockDelegate verify];
}

@end
