//
//  AMBSendCompletionTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBSendCompletionModal.h"

@interface AMBSendCompletionModal (Test)

- (IBAction)buttonPressed:(UIButton *)sender;
- (void)setUpTheme;

@end


@interface AMBSendCompletionTests : XCTestCase

@property (nonatomic, strong) AMBSendCompletionModal * sendCompletion;
@property (nonatomic) id mockVC;

@end

@implementation AMBSendCompletionTests

- (void)setUp {
    [super setUp];
    if (!self.sendCompletion) {
        self.sendCompletion = [[AMBSendCompletionModal alloc] init];
    }
    
    self.mockVC = [OCMockObject partialMockForObject:self.sendCompletion];
}

- (void)tearDown {
    [self.mockVC stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    [[self.mockVC expect] setUpTheme];
    
    // WHEN
    [self.sendCompletion viewDidLoad];
    
    // THEN
    [self.mockVC verify];
}


#pragma mark - IBActions Tests

- (void)testButtonPress {
    // GIVEN
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    [[[self.mockVC expect] andReturn:mockPresentingVC] presentingViewController];
    [[[mockPresentingVC expect] andDo:nil] dismissViewControllerAnimated:NO completion:[OCMArg any]];
    
    // WHEN
    [self.sendCompletion buttonPressed:[OCMArg any]];
    
    // THEN
    [mockPresentingVC verify];
}


#pragma mark - UI Function Tests


@end
