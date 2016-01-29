//
//  NamePrompt.m
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBNamePrompt.h"
#import "AMBUtilities.h"
#import "AMBConstants.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBNetworkManager.h"
#import "AMBThemeManager.h"

@interface AMBNamePrompt () <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;
@property (nonatomic, strong) IBOutlet UIView * firstNameUnderLineView;
@property (nonatomic, strong) IBOutlet UIView * lastNameUnderLineView;
@property (nonatomic, strong) IBOutlet UILabel * lblError;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * topConstraint;

@end

@implementation AMBNamePrompt

CGFloat originalTopConstraintValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    originalTopConstraintValue = self.topConstraint.constant; // Put in 'viewDidAppear' so that the correct sizes are guaranteed to be displayed
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // Removes self from getting and responding to keyboard notifications
}


#pragma mark - IBActions

- (IBAction)btnCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)continueSending:(UIButton *)sender {
    NSString *firstName = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastName = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self checkForBlankNames:firstName lastName:lastName];
    
    if ([self textFieldIsValid:firstName] && [self textFieldIsValid:lastName]) {
        [[AMBNetworkManager sharedInstance] updateNameWithFirstName:firstName lastName:lastName success:^(NSDictionary *response) {
            [AMBValues setUserFirstNameWithString:firstName];
            [AMBValues setUserLastNameWithString:lastName];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.delegate namesUpdatedSuccessfully];
        } failure:^(NSString *error) {
            [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to update names.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
        }];
    }
}


#pragma mark - Navigation

- (void)backButtonPressed:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TextField Delegate

- (BOOL)textField:(nonnull UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    [self removeErrors];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Keyboard Delegates

- (void)keyboardWillShow:(NSNotification*)aNotification {
    CGRect keyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat comparedHeight = self.view.frame.size.height - (self.lastNameUnderLineView.frame.origin.y + self.lastNameUnderLineView.frame.size.height + 10);
    
    if (keyboardFrame.size.height > comparedHeight) {
        self.topConstraint.constant = -(keyboardFrame.size.height - comparedHeight);
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (self.topConstraint.constant != originalTopConstraintValue) {
        self.topConstraint.constant = originalTopConstraintValue;
        [self.view layoutIfNeeded];
    }
}


#pragma mark - UI Functions

- (void)setUpTheme {
    self.continueButton.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    self.continueButton.layer.cornerRadius = self.continueButton.frame.size.height/2;
    self.firstNameField.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    self.lastNameField.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    [self.btnClose setImage:[AMBValues imageFromBundleWithName:@"close" type:@"png" tintable:NO] forState:UIControlStateNormal];
    self.lblError.alpha = 0;
}

- (void)checkForBlankNames:(NSString*)firstName lastName:(NSString*)lastName {
    [UIView animateWithDuration:0.3 animations:^{
        self.firstNameUnderLineView.backgroundColor = (![self textFieldIsValid:firstName]) ? [UIColor redColor] : [UIColor lightGrayColor];
        self.lastNameUnderLineView.backgroundColor = (![self textFieldIsValid:lastName]) ? [UIColor redColor] : [UIColor lightGrayColor];
        self.lblError.alpha =  (![self textFieldIsValid:firstName] || ![self textFieldIsValid:lastName]) ? 1 : 0;
    }];
}

- (void)removeErrors {
    [UIView animateWithDuration:0.3 animations:^{
        self.firstNameUnderLineView.backgroundColor = [UIColor lightGrayColor];
        self.lastNameUnderLineView.backgroundColor = [UIColor lightGrayColor];
        self.lblError.alpha = 0;
    }];
}


#pragma mark - Helper Functions

- (BOOL)textFieldIsValid:(NSString *)string {
    NSString *formattedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ![formattedString isEqualToString:@""];
}

@end
