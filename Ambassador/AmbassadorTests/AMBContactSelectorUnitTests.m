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
@property (nonatomic, strong) NSMutableSet *selected;
@property (nonatomic, strong) IBOutlet UITextField *searchBar;
@property (nonatomic) BOOL isEditing;

- (IBAction)clearAllButtonTapped:(id)sender;
- (IBAction)sendButtonTapped:(id)sender;
- (IBAction)doneSearchingButtonTapped:(id)sender;
- (IBAction)editMessageButtonTapped:(id)sender;
- (void)setUpTheme;
- (void)registerForKeyboardNotifications;
- (BOOL)messageContainsURL;
- (void)sendMessage;
- (void)refreshAllIncludingContacts:(BOOL)refreshContactsTable;
- (void)showOrHideSearchDoneButton;

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


#pragma mark - IBActions Tests

- (void)testSendButton {
    // GIVEN
    [[[self.mockSelector expect] andReturnValue:OCMOCK_VALUE(YES)] messageContainsURL];
    [[[self.mockSelector expect] andDo:nil] sendMessage];
    
    // WHEN
    [self.contactSelector sendButtonTapped:nil];
    
    // THEN
    [self.mockSelector verify];
}

- (void)testClearAllButton {
    // GIVEN
    id mockSeleted = [OCMockObject mockForClass:[NSMutableArray class]];
    self.contactSelector.selected = mockSeleted;
    [[[mockSeleted expect] andDo:nil] removeAllObjects];
    [[[self.mockSelector expect] andDo:nil] refreshAllIncludingContacts:YES];
    
    // WHEN
    [self.contactSelector clearAllButtonTapped:nil];
    
    // THEN
    [mockSeleted verify];
    [self.mockSelector verify];
}

- (void)testDoneSearchingTapped {
    // GIVEN
    id mockSearch = [OCMockObject mockForClass:[UITextField class]];
    self.contactSelector.searchBar = mockSearch;
    [[[mockSearch expect] andDo:nil] resignFirstResponder];
    [[[mockSearch expect] andDo:nil] setText:[OCMArg any]];
    [[[self.mockSelector expect] andDo:nil] showOrHideSearchDoneButton];
    
    // WHEN
    [self.contactSelector doneSearchingButtonTapped:nil];
    
    // THEN
    [mockSearch verify];
    [self.mockSelector verify];
}

- (void)testEditMessageTappedEditing {
    // GIVEN
    self.contactSelector.isEditing = NO;
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] addFadeToView:[OCMArg any]];
    
    // WHEN
    [self.contactSelector editMessageButtonTapped:nil];
    
    // THEN
    [mockUtils verify];
}

- (void)testEditMessageTappedNotEditing {
    // GIVEN
    self.contactSelector.isEditing = YES;
    id mockUtils = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[[mockUtils expect] andDo:nil] removeFadeFromView];
    
    // WHEN
    [self.contactSelector editMessageButtonTapped:nil];
    
    // THEN
    [mockUtils verify];
}

@end
