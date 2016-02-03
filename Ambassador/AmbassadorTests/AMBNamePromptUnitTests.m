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

@interface AMBNamePrompt (Test) <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet NSLayoutConstraint * topConstraint;
@property (nonatomic, strong) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameField;

- (void)setUpTheme;
- (void)checkForBlankNames:(NSString*)firstName lastName:(NSString*)lastName;
- (IBAction)btnCloseTapped:(id)sender;
- (IBAction)continueSending:(UIButton *)sender;
- (void)backButtonPressed:(UIButton *)button;
- (void)removeErrors;

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
    
    [[[self.mockNamePrompt expect] andDo:nil] checkForBlankNames:firstName lastName:lastName];
    
    // WHEN
    [self.namePrompt continueSending:nil];
    
    // THEN
    [self.mockNamePrompt verify];
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
    id mockTF = [OCMockObject partialMockForObject:self.namePrompt.firstNameField];
    [[[mockTF expect] andDo:nil] resignFirstResponder];
    
    // WHEN
    [self.namePrompt textFieldShouldReturn:mockTF];
    
    // THEN
    [mockTF resignFirstResponder];
}

@end
