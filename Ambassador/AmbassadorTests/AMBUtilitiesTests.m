//
//  AMBUtilitiesTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBUtilities.h"
#import <OCMock/OCMock.h>
#import "AMBSendCompletionModal.h"

@interface AMBUtilities (Test)

- (void)startSpinner;
- (void)hideLoadingView;

@end


@interface AMBUtilitiesTests : XCTestCase

@property (nonatomic, strong) AMBUtilities * utilities;
@property (nonatomic) id mockViewController;
@property (nonatomic) id mockUtilities;

@end

@implementation AMBUtilitiesTests

- (void)setUp {
    [super setUp];
    if (!self.utilities) {
        self.utilities = [AMBUtilities sharedInstance];
    }
    
    self.mockViewController = [OCMockObject mockForClass:[UIViewController class]];
    self.mockUtilities = [OCMockObject partialMockForObject:self.utilities];
}

- (void)tearDown {
    [self.mockViewController stopMocking];
    [self.mockUtilities stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testSharedInstance {
    XCTAssertNotNil([AMBUtilities sharedInstance]);
}


#pragma mark - Custom Alert

- (void)testPresentAlert {
    // GIVEN
    NSString *alertMessage = @"Alert message";
    BOOL successful = YES;
    
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    id mockSB = [OCMockObject mockForClass:[UIStoryboard class]];
    id mockVC = [OCMockObject mockForClass:[AMBSendCompletionModal class]];
    [[[mockSB expect] andReturn:mockSB] storyboardWithName:@"Main" bundle:[OCMArg any]];
    [[[mockSB expect] andReturn:mockVC] instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    
    [[[mockVC expect] andDo:nil] setAlertMessage:alertMessage];
    [[[mockVC expect] andDo:nil] shouldUseSuccessIcon:successful];
    [[[mockVC expect] andDo:nil] setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [[[mockVC expect] andDo:nil] setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [[[mockVC expect] andDo:nil] setButtonAction:[OCMArg any]];
    
    [[[mockPresentingVC expect] andDo:nil] presentViewController:mockVC animated:YES completion:nil];
    
    // WHEN
    [self.utilities presentAlertWithSuccess:successful message:alertMessage withUniqueID:nil forViewController:mockPresentingVC shouldDismissVCImmediately:NO];
    
    // THEN
    [mockSB verify];
    [mockVC verify];
    [mockPresentingVC verify];
}


#pragma mark - Loading Screen Tests

- (void)testShowLoadingScreen {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    
    for (int i = 0; i < 4; i++) {
        [[[mockView expect] andDo:nil] frame];
    }
    
    [[[mockView expect] andDo:nil] addSubview:[OCMArg isKindOfClass:[UIView class]]];
    
    // WHEN
    [self.utilities showLoadingScreenForView:mockView];
    
    // THEN
    [mockView verify];
}

- (void)testStartSpinner {
    // GIVEN
    id mockAnimatingViewLayer = [OCMockObject mockForClass:[CALayer class]];
    [[[mockAnimatingViewLayer expect] andDo:nil] addAnimation:[OCMArg isKindOfClass:[CABasicAnimation class]] forKey:[OCMArg isKindOfClass:[NSString class]]];
    
    self.mockUtilities = [OCMockObject partialMockForObject:self.utilities];
    id mockAnimatingView = [OCMockObject mockForClass:[UIView class]];
    
    [[[self.mockUtilities expect] andReturn:mockAnimatingView] animatingView];
    [[[mockAnimatingView expect] andReturn:mockAnimatingViewLayer] layer];
    
    // WHEN
    [self.utilities startSpinner];
    
    // THEN
    [self.mockUtilities verify];
    [mockAnimatingViewLayer verify];
    [mockAnimatingView verify];
}

- (void)testHideLoadingView {
    // GIVEN
    self.utilities.loadingView = [[UIView alloc ] init];
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[mockView expect] animateWithDuration:0.3 animations:[OCMArg any] completion:[OCMArg any]];
    
    // WHEN
    [self.utilities hideLoadingView];
    
    // THEN
    [mockView verify];
}

- (void)testRotateLoadingView {
    // GIVEN
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeRight;
    
    id mockAnimatingView = [OCMockObject mockForClass:[UIView class]];
    [[[self.mockUtilities expect] andReturn:mockAnimatingView] animatingView];
    [[[mockAnimatingView expect] andDo:nil] setFrame:CGRectMake(200, 200, 100, 100)];
    
    // WHEN
    [self.utilities rotateLoadingView:view orientation:orientation];
    
    // THEN
    [self.mockUtilities verify];
}

@end
