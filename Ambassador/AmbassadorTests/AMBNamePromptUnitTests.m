//
//  AMBNamePromptUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBNamePrompt.h"

@interface AMBNamePrompt (Test)

@property (nonatomic, strong) IBOutlet NSLayoutConstraint * topConstraint;

- (void)setUpTheme;

@end


@interface AMBNamePromptUnitTests : XCTestCase

@property (nonatomic, strong) AMBNamePrompt * namePrompt;
@property (nonatomic) id mockNamePrompt;

@end

@implementation AMBNamePromptUnitTests

- (void)setUp {
    [super setUp];
    if (!self.namePrompt) {
        self.namePrompt = [[AMBNamePrompt alloc] init];
    }
    
    self.mockNamePrompt = [OCMockObject partialMockForObject:self.namePrompt];
}

- (void)tearDown {
    [self.mockNamePrompt stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    [[[self.mockNamePrompt expect] andDo:nil] setUpTheme];
    
    // WHEN
    [self.namePrompt viewDidLoad];
    
    // THEN
    [self.mockNamePrompt verify];
}

- (void)testViewDidAppear {
    // GIVEN
    self.namePrompt.topConstraint.constant = 100;
    
    // WHEN
    CGFloat mockOriginalConstraint = self.namePrompt.topConstraint.constant;
    
    // THEN
    XCTAssertEqual(mockOriginalConstraint, self.namePrompt.topConstraint.constant);
}

- (void)testViewWillDisappear {
    // GIVEN
    id mockObserver = [OCMockObject partialMockForObject:[NSNotificationCenter defaultCenter]];
    [[[mockObserver expect] andDo:nil] removeObserver:[OCMArg any]];
    
    // WHEN
    [self.namePrompt viewWillDisappear:YES];
    
    // THEN
    [mockObserver verify];
}

@end
