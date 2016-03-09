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

@interface AMBUtilities (Test) <AMBSendCompletionDelegate>

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
    BOOL shouldDismiss = NO;
    
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    id mockSB = [OCMockObject mockForClass:[UIStoryboard class]];
    id mockVC = [OCMockObject mockForClass:[AMBSendCompletionModal class]];
    [[[mockSB expect] andReturn:mockSB] storyboardWithName:@"Main" bundle:[OCMArg any]];
    [[[mockSB expect] andReturn:mockVC] instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    
    [[[mockVC expect] andDo:nil] setAlertMessage:alertMessage];
    [[[mockVC expect] andDo:nil] setShowSuccess: successful];
    [[[mockVC expect] andDo:nil] setPresentingVC:[OCMArg isKindOfClass:[UIViewController class]]];
    [[[mockVC expect] andDo:nil] setShouldDismissPresentingVC:shouldDismiss];
    [[[mockVC expect] andDo:nil] setUniqueIdentifier:nil];
    [[[mockVC expect] andDo:nil] setDelegate:[OCMArg any]];
    [[[mockVC expect] andDo:nil] setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [[[mockVC expect] andDo:nil] setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [[[mockPresentingVC expect] andDo:nil] presentViewController:mockVC animated:YES completion:nil];
    
    // WHEN
    [self.utilities presentAlertWithSuccess:successful message:alertMessage withUniqueID:nil forViewController:mockPresentingVC shouldDismissVCImmediately:NO];
    
    // THEN
    [mockSB verify];
    [mockVC verify];
    [mockPresentingVC verify];
}

- (void)testButtonClickDelegateFunction {
    // GIVEN
    BOOL dismissPresenter = YES;
    NSString *uniqueID = @"unique";
    
    id mockVC = [OCMockObject mockForClass:[UIViewController class]];
    [[[mockVC expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.utilities buttonClickedWithPresentingVC:mockVC shouldDismissPresentingVC:dismissPresenter uniqueID:uniqueID];
    
    // THEN
    [mockVC verify];
}


#pragma mark - Loading Screen Tests

- (void)testShowLoadingScreen {
    // GIVEN
    self.utilities.loadingView = nil;
    id mockView = [OCMockObject mockForClass:[UIView class]];
    
    for (int i = 0; i < 4; i++) {
        [[[mockView expect] andDo:nil] frame];
    }
    
    [[[mockView expect] andDo:nil] addSubview:[OCMArg isKindOfClass:[UIView class]]];
    
    [[[mockView expect] andDo:^(NSInvocation *invocation) {
        void (^animations)() = nil;
        [invocation getArgument:&animations atIndex:4];
        animations();
    }] animateWithDuration:0.3 animations:[OCMArg invokeBlock] completion:[OCMArg any]];
    
    // WHEN
    [self.utilities showLoadingScreenForView:mockView];
    
    // THEN
    [mockView verify];
}

- (void)testStartSpinner {
    // GIVEN
    id mockAnimatingViewLayer = [OCMockObject mockForClass:[CALayer class]];
    [[[mockAnimatingViewLayer expect] andDo:nil] addAnimation:[OCMArg isKindOfClass:[CABasicAnimation class]] forKey:[OCMArg isKindOfClass:[NSString class]]];
    
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
    
    id mockLoadingView = [OCMockObject partialMockForObject:self.utilities.loadingView];
    id mockView = [OCMockObject mockForClass:[UIView class]];
    
//    [[mockView expect] animateWithDuration:0.3 animations:[OCMArg any] completion:[OCMArg any]];
    
    [[[mockView expect] andDo:^(NSInvocation *invocation) {
        void (^completion)(BOOL finished) = nil;
        [invocation getArgument:&completion atIndex:4];
        completion(YES);
    }] animateWithDuration:0.3 animations:[OCMArg any] completion:[OCMArg invokeBlock]];
    [[[mockLoadingView expect] andDo:nil] removeFromSuperview];
    
    
    // WHEN
    [self.utilities hideLoadingView];
    
    // THEN
    [mockLoadingView verify];
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


#pragma mark - FadeView Tests

- (void)testAddFadeToView {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[mockView expect] andDo:nil] frame];
    [[[mockView expect] andDo:nil] addSubview:[OCMArg isKindOfClass:[UIView class]]];
    [[[mockView expect] andDo:nil] animateWithDuration:0.3 animations:[OCMArg any]];
    
    // WHEN
    [self.utilities addFadeToView:mockView];
    
    // THEN
    [mockView verify];
}

- (void)testRemoveFadeView {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[mockView expect] animateWithDuration:0.3 animations:[OCMArg any] completion:[OCMArg any]];
    
    // WHEN
    [self.utilities removeFadeFromView];
    
    // THEN
    [mockView verify];
}

- (void)testRotateFadeForView {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    id mockFadeView = [OCMockObject mockForClass:[UIView class]];
    self.utilities.fadeView = mockFadeView;
    
    [[[mockFadeView expect] andReturnValue:OCMOCK_VALUE(YES)] isDescendantOfView:mockView];
    [[[mockView expect] andDo:nil] frame];
    [[[mockView expect] andDo:nil] frame];
    [[[mockFadeView expect] andDo:nil] setFrame:[mockView frame]];
    [[[mockView expect] andDo:nil] bringSubviewToFront:mockFadeView];
    
    // WHEN
    [self.utilities rotateFadeForView:mockView];
    
    // THEN
    [mockView verify];
    [mockFadeView verify];
}


#pragma mark - Misc Class Functions

- (void)testCreateRequestID {
    // GIVEN
    NSString *firstRequestID = [AMBUtilities createRequestID];
    
    // WHEN
    NSString *secondRequestID = [AMBUtilities createRequestID];
    
    // THEN
    XCTAssertEqual([secondRequestID floatValue], [firstRequestID floatValue]);
    XCTAssertNotNil(firstRequestID);
    XCTAssertNotNil(secondRequestID);
}

- (void)testColorIsDark {
    // GIVEN
    UIColor *darkColor = [UIColor blackColor];
    UIColor *lightColor = [UIColor whiteColor];
    
    // WHEN
    BOOL isDarkTrue = [AMBUtilities colorIsDark:darkColor];
    BOOL isDarkFalse = [AMBUtilities colorIsDark:lightColor];
    
    // THEN
    XCTAssertTrue(isDarkTrue);
    XCTAssertFalse(isDarkFalse);
}

- (void)testIsSuccessfulStatusCode {
    // GIVEN
    NSInteger successfulCode = 200;
    NSInteger unsuccessfulCode = 300;
    
    // WHEN
    BOOL isSuccessfulTrue = [AMBUtilities isSuccessfulStatusCode:successfulCode];
    BOOL isSuccessfulFalse = [AMBUtilities isSuccessfulStatusCode:unsuccessfulCode];
    
    // THEN
    XCTAssertTrue(isSuccessfulTrue);
    XCTAssertFalse(isSuccessfulFalse);
}

- (void)testDictionaryFromQueryString {
    // GIVEN
    NSString *fakeQueryString = @"test1key=test1&test2key=test2";
    NSDictionary *expectedDict = @{@"test1key" : @"test1", @"test2key" : @"test2"};
    
    // WHEN
    NSDictionary *resultDict = [AMBUtilities dictionaryFromQueryString:fakeQueryString];
    
    // THEN
    XCTAssertEqualObjects(expectedDict[@"testkey1"], resultDict[@"testkey1"]);
    XCTAssertEqualObjects(expectedDict[@"testkey2"], resultDict[@"testkey2"]);
}

- (void)testCreate32CharCode {
    // WHEN
    NSString *randomString = [AMBUtilities create32CharCode];
    
    // THEN
    XCTAssertEqual(randomString.length, 32);
}

- (void)testStringIsEmpty {
    // GIVEN
    NSString *emptyString = @"";
    NSString *nonEmtpyString = @"test";
    
    // WHEN
    BOOL emptyTest1 = [AMBUtilities stringIsEmpty:emptyString];
    BOOL emptyTest2 = [AMBUtilities stringIsEmpty:nonEmtpyString];
    
    // THEN
    XCTAssertTrue(emptyTest1);
    XCTAssertFalse(emptyTest2);
}

@end
