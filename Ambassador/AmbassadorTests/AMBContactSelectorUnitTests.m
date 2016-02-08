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
#import "AMBContactCell.h"
#import "AMBContact.h"
#import "AMBNetworkManager.h"
#import "AMBBulkShareHelper.h"

@interface AMBContactSelector (Test) <UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIView * containerView;
@property (nonatomic, strong) NSMutableSet *selected;
@property (nonatomic, strong) IBOutlet UITextField *searchBar;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL activeSearch;
@property (nonatomic, strong) IBOutlet UITableView *contactsTable;
@property (nonatomic, strong) NSMutableArray *filteredData;

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
- (void)searchWithText:(NSString *)searchText;
- (void)keyboardWillShow:(NSNotification*)sender;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (BOOL)alreadyHaveNames;
- (void)sendSMS;
- (void)sendEmail;

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


#pragma mark - TableView DataSource Tests

- (void)testTableNumberOfRows {
    // GIVEN
    id mockContactTable = [OCMockObject mockForClass:[UITableView class]];
    self.contactSelector.contactsTable = mockContactTable;
    
    self.contactSelector.activeSearch = YES;
    self.contactSelector.filteredData = [NSMutableArray arrayWithObject:@"data"];
    
    // WHEN
    NSInteger numRows = [self.contactSelector tableView:mockContactTable numberOfRowsInSection:0];
    
    // THEN
    XCTAssertEqual(numRows, [self.contactSelector.filteredData count]);
}

- (void)testTableCellForRow {
    // GIVEN
    self.contactSelector.activeSearch = YES;
    id mockContact = [OCMockObject mockForClass:[AMBContact class]];
    
    id mockArray = [OCMockObject mockForClass:[NSMutableArray class]];
    self.contactSelector.filteredData = mockArray;
    [[[mockArray expect] andReturn:mockContact] objectAtIndexedSubscript:0];
    
    id mockContactTable = [OCMockObject mockForClass:[UITableView class]];
    self.contactSelector.contactsTable = mockContactTable;
    
    id mockCell = [OCMockObject mockForClass:[AMBContactCell class]];
    [[[mockContactTable expect] andReturn:mockCell] dequeueReusableCellWithIdentifier:@"contactCell"];
    [[[mockCell expect] andDo:nil] setUpCellWithContact:[OCMArg any] isSelected:NO];
    [[[mockCell expect] andDo:nil] setDelegate:[OCMArg any]];
    
    // WHEN
    [self.contactSelector tableView:mockContactTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // THEN
    [mockContactTable verify];
    [mockCell verify];
    [mockArray verify];
}


#pragma mark - TextField delegate tests

- (void)testFieldDidBeginEditing {
    // GIVEN
    [[[self.mockSelector expect] andDo:nil] showOrHideSearchDoneButton];
    
    // WHEN
    [self.contactSelector textFieldDidBeginEditing:self.contactSelector.searchBar];
    
    // THEN
    [self.mockSelector verify];
}

- (void)testFieldShouldChangeCharacter {
    // GIVEN
    NSRange mockRange = NSRangeFromString(@"test");
    NSString *stringValue = @"test";
    
    id mockTextField = [OCMockObject mockForClass:[UITextField class]];
    id mockString = [OCMockObject mockForClass:[NSString class]];
    
    
    [[[mockTextField expect] andReturn:mockString] text];
    [[[mockString expect] andReturnValue:OCMOCK_VALUE(stringValue)] stringByReplacingCharactersInRange:mockRange withString:[OCMArg any]];
    
    [[[self.mockSelector expect] andDo:nil] searchWithText:stringValue];
    
    // WHEN
    [self.contactSelector textField:mockTextField shouldChangeCharactersInRange:mockRange replacementString:stringValue];
    
    // THEN
    [mockTextField verify];
    [mockString verify];
    [self.mockSelector verify];
}

- (void)testFieldShouldReturn {
    // GIVEN
    id mockField = [OCMockObject mockForClass:[UITextField class]];
    [[[mockField expect] andDo:nil] resignFirstResponder];
    
    // WHEN
    BOOL expectedBool = [self.contactSelector textFieldShouldReturn:mockField];
    
    // THEN
    XCTAssertTrue(expectedBool);
    [mockField verify];
}


#pragma mark - UITextView Delegate Tests

- (void)testViewShouldBeginEditing {
    // GIVEN
    self.contactSelector.isEditing = NO;
    [[[self.mockSelector expect] andDo:nil] editMessageButtonTapped:nil];
    
    id mockTextView = [OCMockObject mockForClass:[UITextView class]];
    
    // WHEN
    BOOL expectedBool = [self.contactSelector textViewShouldBeginEditing:mockTextView];
    
    // THEN
    XCTAssertTrue(expectedBool);
    [self.mockSelector verify];
}


#pragma mark - Keyboard Tests

- (void)testRegisterForKeyboardNotif {
    // GIVEN
    id mockNotif = [OCMockObject partialMockForObject:[NSNotificationCenter defaultCenter]];
    [[[mockNotif expect] andDo:nil] addObserver:self.contactSelector selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[[mockNotif expect] andDo:nil] addObserver:self.contactSelector selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    // WHEN
    [self.contactSelector registerForKeyboardNotifications];
    
    // THEN
    [mockNotif verify];
}

- (void)testKeyboardWillShow {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[self.mockSelector expect] andReturn:mockView] view];
    [[[mockView expect] andDo:nil] layoutIfNeeded];
    
    // WHEN
    [self.contactSelector keyboardWillShow:nil];
    
    // THEN
    [mockView verify];
}


#pragma mark - Send Function Tests

- (void)testSendSMS {
    // GIVEN
    [[[self.mockSelector expect] andReturnValue:OCMOCK_VALUE(NO)] alreadyHaveNames];
    [[[self.mockSelector expect] andDo:nil] performSegueWithIdentifier:[OCMArg any] sender:self.contactSelector];
    
    // WHEN
    [self.contactSelector sendSMS];
    
    // THEN
    [self.mockSelector verify];
}

- (void)testSendSMSWithNames {
    // GIVEN
    NSArray *array = @[@"555-555-5555"];
    
    id mockBulkShare = [OCMockObject mockForClass:[AMBBulkShareHelper class]];
    [[[mockBulkShare expect] andReturnValue:OCMOCK_VALUE(array)] validatedPhoneNumbers:[OCMArg any]];
    
    [[[self.mockSelector expect] andReturnValue:OCMOCK_VALUE(YES)] alreadyHaveNames];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:nil] bulkShareSmsWithMessage:[OCMArg any] phoneNumbers:array success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.contactSelector sendSMS];
    
    // THEN
    [mockBulkShare verify];
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
    [self.mockSelector verify];
}

- (void)testSendEmail {
    // GIVEN
    NSArray *array = @[@"test@example.com"];
    
    id mockBulkShare = [OCMockObject mockForClass:[AMBBulkShareHelper class]];
    [[[mockBulkShare expect] andReturnValue:OCMOCK_VALUE(array)] validatedEmails:[OCMArg any]];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:nil] bulkShareEmailWithMessage:[OCMArg any] emailAddresses:array success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.contactSelector sendEmail];
    
    // THEN
    [mockBulkShare verify];
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
}

@end
