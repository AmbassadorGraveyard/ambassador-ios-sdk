//
//  AMBContactSelectorUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/8/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBUtilities.h"
#import "AMBThemeManager.h"
#import "AMBContactSelector.h"

@interface AMBContactSelector (Test)

@property (nonatomic, strong) IBOutlet UIView * containerView;

- (IBAction)sendButtonTapped:(id)sender;

- (void)setUpTheme;
- (void)registerForKeyboardNotifications;
- (BOOL)messageContainsURL;
- (void)sendMessage;

@end


@interface AMBContactSelectorUnitTests : XCTestCase

@property (nonatomic, strong) AMBContactSelector * contactSelector;
@property (nonatomic) id mockSelector;

@end

@implementation AMBContactSelectorUnitTests

- (void)setUp {
    [super setUp];
    if (!self.contactSelector) {
        [[AMBThemeManager sharedInstance] createDicFromPlist:@"GenericTheme"];
        self.contactSelector = [[AMBContactSelector alloc] init];
    }
    
    self.mockSelector = [OCMockObject partialMockForObject:self.contactSelector];
}

- (void)tearDown {
    [self.mockSelector stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    NSString *expectedTitle = @"Refer your friends";
    [[[self.mockSelector expect] andDo:nil] setUpTheme];
    [[[self.mockSelector expect] andDo:nil] registerForKeyboardNotifications];
    
    // WHEN
    [self.contactSelector viewDidLoad];
    
    // THEN
    [self.mockSelector verify];
    XCTAssertEqualObjects(expectedTitle, self.contactSelector.title);
}

- (void)testWillRotate {
    // GIVEN
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] rotateLoadingView:self.contactSelector.view orientation:UIInterfaceOrientationLandscapeLeft];
    [[[mockUtils expect] andDo:nil] rotateFadeForView:self.contactSelector.containerView];
    
    // WHEN
    [self.contactSelector willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:1.0];
    
    // THEN
    [mockUtils verify];
}

- (void)testViewWillDisappear {
    // GIVEN
    id mockDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockDefaults expect] andDo:nil] setValue:@(YES) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    // WHEN
    [self.contactSelector viewWillDisappear:YES];
    
    // THEN
    [mockDefaults verify];
}

@end
