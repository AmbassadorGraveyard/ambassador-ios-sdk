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
#import "AMBThemeManager.h"

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
    [[[mockPresentingVC expect] andDo:^(NSInvocation *invocation) {
        void (^completion)() = nil;
        [invocation getArgument:&completion atIndex:3];
        completion();
    }] dismissViewControllerAnimated:NO completion:[OCMArg invokeBlock]];
    
    
    // WHEN
    [self.sendCompletion buttonPressed:[OCMArg any]];
    
    // THEN
    [mockPresentingVC verify];
}


#pragma mark - UI Function Tests

- (void)testSetUpTheme {
    // GIVEN
    id mockThemeMgr = [OCMockObject partialMockForObject:[AMBThemeManager sharedInstance]];
    [[mockThemeMgr expect] colorForKey:AlertButtonBackgroundColor];
    [[mockThemeMgr expect] colorForKey:AlertButtonTextColor];
    
    // WHEN
    [self.sendCompletion setUpTheme];
    
    // THEN
    [mockThemeMgr verify];
}

@end
