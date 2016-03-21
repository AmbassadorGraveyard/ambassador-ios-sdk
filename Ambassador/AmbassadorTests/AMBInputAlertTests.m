//
//  AMBInputAlertTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBInputAlert.h"

@interface AMBInputAlert (Tests) <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField * tfInput;

- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (void)setUpUI;
- (void)showErrorLine;
- (void)hideErrorLine;

@end


@interface AMBInputAlertTests : XCTestCase

@property (nonatomic, strong) AMBInputAlert * inputAlert;
@property (nonatomic) id mockInput;

@end

@implementation AMBInputAlertTests

- (void)setUp {
    [super setUp];
    if (!self.inputAlert) {
        self.inputAlert = [[AMBInputAlert alloc] init];
    }
    
    self.mockInput = [OCMockObject partialMockForObject:self.inputAlert];
}

- (void)tearDown {
    [self.mockInput stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testInitWithTitle {
    // GIVEN
    id mockSb = [OCMockObject mockForClass:[UIStoryboard class]];
    [[[mockSb expect] andReturn:mockSb] storyboardWithName:@"Main" bundle:[OCMArg any]];
    [[[mockSb expect] andDo:nil] instantiateViewControllerWithIdentifier:@"AMBCustomInput"];
    
    // WHEN
    self.inputAlert = [[AMBInputAlert alloc] initWithTitle:@"test" message:@"test" placeHolder:@"test" actionButton:@"test"];
    
    // THEN
    [mockSb verify];
    [mockSb stopMocking];
}

- (void)testViewDidLoad {
    // GIVEN
    [[[self.mockInput expect] andDo:nil] setUpUI];
    
    // WHEN
    [self.inputAlert viewDidLoad];
    
    // THEN
    [self.mockInput verify];
}


#pragma mark - IBAction Tests

- (void)testActionButtonTappedValid {
    // GIVEN
    NSString *emailValue = @"email@test.com";
    self.inputAlert.tfInput = [[UITextField alloc] init];
    self.inputAlert.tfInput.text = emailValue;
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBInputAlertDelegate)];
    [[[mockDelegate expect] andDo:nil] AMBInputAlertActionButtonTapped:emailValue];
    self.inputAlert.delegate = mockDelegate;
    
    
    [[[self.mockInput expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.inputAlert actionButtonTapped:nil];
    
    // THEN
    [mockDelegate verify];
    [self.mockInput verify];
    
    [mockDelegate stopMocking];
}

- (void)testActionButtonTappedInvalid {
    // GIVEN
    self.inputAlert.tfInput = [[UITextField alloc] init];
    self.inputAlert.tfInput.text = @" ";
    [[[self.mockInput expect] andDo:nil] showErrorLine];
    
    // WHEN
    [self.inputAlert actionButtonTapped:nil];
    
    // THEN
    [self.mockInput verify];
}

- (void)testCloseButton {
    // GIVEN
    [[[self.mockInput expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.inputAlert closeButtonTapped:nil];
    
    // THEN
    [self.mockInput verify];
}


#pragma mark - UITextField Delegate Tests

- (void)testTextFieldCharacterChange {
    // GIVEN
    [[[self.mockInput expect] andDo:nil] hideErrorLine];
    
    // WHEN
    [self.mockInput textField:self.inputAlert.tfInput shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"test"];
    
    // THEN
    [self.mockInput verify];
}

- (void)testTextFieldShouldReturn {
    // GIVEN
    id mockTf = [OCMockObject mockForClass:[UITextField class]];
    [[[mockTf expect] andDo:nil] resignFirstResponder];
    self.inputAlert.tfInput = mockTf;
    
    // WHEN
    [self.inputAlert textFieldShouldReturn:self.inputAlert.tfInput];
    
    [mockTf verify];
    [mockTf stopMocking];
}

@end
