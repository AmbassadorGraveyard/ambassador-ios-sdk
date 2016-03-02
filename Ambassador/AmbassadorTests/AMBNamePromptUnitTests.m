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
#import "AMBNetworkManager.h"
#import "AMBThemeManager.h"

@interface AMBNamePrompt (Test) <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet NSLayoutConstraint * topConstraint;
@property (nonatomic, strong) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;

- (void)setUpTheme;
- (void)checkForBlankNames:(NSString*)firstName lastName:(NSString*)lastName;
- (IBAction)btnCloseTapped:(id)sender;
- (IBAction)continueSending:(UIButton *)sender;
- (void)backButtonPressed:(UIButton *)button;
- (void)removeErrors;
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (BOOL)textFieldIsValid:(NSString *)string;

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
    [self.namePrompt viewDidAppear:YES];
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


#pragma mark - IBActions Tests

- (void)testBtnCloseTapped {
    // GIVEN
    [[[self.mockNamePrompt expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.namePrompt btnCloseTapped:nil];
    
    // THEN
    [self.mockNamePrompt verify];
}

- (void)testContinueSending {
    // GIVEN
    NSString *firstName = @"FirstName";
    NSString *lastName = @"LastName";
    
    self.namePrompt.firstNameField = [[UITextField alloc] init];
    self.namePrompt.lastNameField = [[UITextField alloc] init];
    self.namePrompt.firstNameField.text = firstName;
    self.namePrompt.lastNameField.text = lastName;
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)(NSDictionary *response) = nil;
        [invocation getArgument:&success atIndex:4];
        success(nil);
    }] updateNameWithFirstName:firstName lastName:lastName success:[OCMArg invokeBlock] failure:[OCMArg any]];
    [[[self.mockNamePrompt expect] andDo:nil] checkForBlankNames:firstName lastName:lastName];
    
    // WHEN
    [self.namePrompt continueSending:nil];
    
    // THEN
    [mockNetworkMgr verify];
    [self.mockNamePrompt verify];
    [mockNetworkMgr stopMocking];
}


#pragma mark - Navigation Tests

- (void)testBackButtonPressed {
    // GIVEN
    id mockNav = [OCMockObject mockForClass:[UINavigationController class]];
    [[[self.mockNamePrompt expect] andReturn:mockNav] navigationController];
    [[[mockNav expect] andDo:nil] popViewControllerAnimated:YES];
    
    // WHEN
    [self.namePrompt backButtonPressed:nil];
    
    // THEN
    [mockNav verify];
}


#pragma mark - TextField Delegate Tests

- (void)testTextFieldShouldChangeCharactersTest {
    // GIVEN
    [[[self.mockNamePrompt expect] andDo:nil] removeErrors];
    
    // WHEN
    [self.namePrompt textField:self.namePrompt.firstNameField shouldChangeCharactersInRange:NSRangeFromString(@"test") replacementString:@"test"];
    
    // THEN
    [self.mockNamePrompt verify];
}

- (void)testTextFieldShouldReturn {
    // GIVEN
    self.namePrompt.firstNameField = [[UITextField alloc] init];
    id mockTF = [OCMockObject mockForClass:[UITextField class]];
    self.namePrompt.firstNameField = mockTF;
    [[[mockTF expect] andDo:nil] resignFirstResponder];
    
    // WHEN
    [self.namePrompt textFieldShouldReturn:self.namePrompt.firstNameField];
    
    // THEN
    [mockTF verify];
}


#pragma mark - UI Function Tests

- (void)testSetUpTheme {
    // GIVEN
    self.namePrompt.continueButton = [[UIButton alloc] init];
    self.namePrompt.firstNameField = [[UITextField alloc] init];
    self.namePrompt.lastNameField = [[UITextField alloc] init];
    
    // WHEN
    [self.namePrompt setUpTheme];
    
    // THEN
    XCTAssertEqualObjects(self.namePrompt.continueButton.backgroundColor, [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor]);
    XCTAssertEqualObjects(self.namePrompt.firstNameField.tintColor, [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor]);
    XCTAssertEqualObjects(self.namePrompt.lastNameField.tintColor, [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor]);
}

- (void)testCheckForBlankNames {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[mockView expect] andDo:^(NSInvocation *invocation) {
        void (^animations)() = nil;
        [invocation getArgument:&animations atIndex:3];
        animations();
    }] animateWithDuration:0.3 animations:[OCMArg any]];
    
    // WHEN
    [self.namePrompt checkForBlankNames:@"firstName" lastName:@"lastName"];
    
    // THEN
    [mockView verify];
}

- (void)testRemoveErrors {
    // GIVEN
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[mockView expect] andDo:^(NSInvocation *invocation) {
        void (^animations)() = nil;
        [invocation getArgument:&animations atIndex:3];
        animations();
    }] animateWithDuration:0.3 animations:[OCMArg any]];
    
    // WHEN
    [self.namePrompt removeErrors];
    
    // THEN
    [mockView verify];
}


#pragma mark - Helper Tests

- (void)testTextFieldIsValid {
    // GIVEN
    NSString *validString = @"test";
    NSString *invalidString = @"";
    
    // WHEN
    BOOL returnTrue = [self.namePrompt textFieldIsValid:validString];
    BOOL returnFalse = [self.namePrompt textFieldIsValid:invalidString];
    
    // THEN
    XCTAssertTrue(returnTrue);
    XCTAssertFalse(returnFalse);
}

@end
