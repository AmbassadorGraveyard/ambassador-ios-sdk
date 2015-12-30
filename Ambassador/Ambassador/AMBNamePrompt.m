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
@property (weak, nonatomic) IBOutlet UILabel *firstNameError;
@property (weak, nonatomic) IBOutlet UILabel *lastNameError;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;
@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIView * firstNameUnderLineView;
@property (nonatomic, strong) IBOutlet UIView * lastNameUnderLineView;
@property (nonatomic, strong) IBOutlet UILabel * lblError;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *viewTapped;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * topConstraint;
@property BOOL firstNameEdited;
@property BOOL lastNameEdited;
@end

@implementation AMBNamePrompt

CGFloat originalTopConstraintValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];

    [self setUpTheme];
    
    // Do any additional setup after loading the view.
    self.continueButton.layer.cornerRadius = self.continueButton.frame.size.height/2;
    
    self.firstNameField.backgroundColor = [UIColor clearColor];
    self.lastNameField.backgroundColor = [UIColor clearColor];
    self.firstNameError.hidden = YES;
    self.lastNameError.hidden = YES;
    self.firstNameField.textColor = [UIColor blackColor];
    self.lastNameField.textColor = [UIColor blackColor];
    [self.viewTapped addTarget:self action:@selector(removeKeyboard)];
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.firstNameEdited = NO;
    self.lastNameEdited = NO;
    
    self.scrollView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    originalTopConstraintValue = self.topConstraint.constant;
}


#pragma mark - IBActions

- (IBAction)btnCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueSending:(UIButton *)sender
{
    [self checkForBlankFirstName];
    [self checkForBlankLastName];
    
    if ([self textFieldIsValid:self.firstNameField.text] && [self textFieldIsValid:self.lastNameField.text]) {
        NSString *firstName = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastName = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        [[AMBNetworkManager sharedInstance] updateNameWithFirstName:firstName lastName:lastName success:^(NSDictionary *response) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate namesUpdatedSuccessfully];
        } failure:^(NSString *error) {
            [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to update names.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
        }];
    }
    
    self.firstNameEdited = YES;
    self.lastNameEdited = YES;
    [self updateErrorLabelForFirstNameString:self.firstNameField.text lastNameString:self.lastNameField.text];
}

- (BOOL)textFieldIsValid:(NSString *)string
{
    NSString *formattedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ![formattedString isEqualToString:@""];
}



#pragma mark - TextFieldDelegate
- (BOOL)textField:(nonnull UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
    NSMutableString *firstNameText = [NSMutableString stringWithString:self.firstNameField.text];
    NSMutableString *lastNameText = [NSMutableString stringWithString:self.lastNameField.text];
    if (textField == self.firstNameField) {
        [firstNameText replaceCharactersInRange:range withString:string];
    } else {
        [lastNameText replaceCharactersInRange:range withString:string];
    }
    [self updateErrorLabelForFirstNameString:firstNameText lastNameString:lastNameText];
    return YES;
}

- (void)updateErrorLabelForFirstNameString:(NSString *)firstString lastNameString:(NSString *)lastString
{
    if (!self.firstNameEdited || !self.lastNameEdited) { return; }
    DLog(@"%@    %@",firstString, lastString);
    if ([self textFieldIsValid:firstString])
    {
        DLog();
        self.firstNameError.hidden = YES;
        //self.firstNameField.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.25];
    }
    else
    {
        DLog();
        self.firstNameError.hidden = NO;
        self.firstNameField.backgroundColor = [UIColor clearColor];
    }
    
    if ([self textFieldIsValid:lastString])
    {
        DLog();
        self.lastNameError.hidden = YES;
        //self.lastNameField.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.25];
    }
    else
    {
        DLog();
        self.lastNameError.hidden = NO;
        self.lastNameField.backgroundColor = [UIColor clearColor];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    if(textField == self.firstNameField)
//    {
//        [self.lastNameField becomeFirstResponder];
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//   
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

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


- (void)removeKeyboard
{
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
        [self.view endEditing:YES];
    }
}


#pragma mark - Helper Functions

- (void)setUpTheme {
    self.continueButton.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    self.lblError.alpha = 0;
}

- (void)checkForBlankFirstName {
    [UIView animateWithDuration:0.3 animations:^{
        self.firstNameUnderLineView.backgroundColor = ([self.firstNameField.text isEqualToString:@""]) ? [UIColor redColor] : [UIColor lightGrayColor];
    }];
}

- (void)checkForBlankLastName {
    [UIView animateWithDuration:0.3 animations:^{
        self.lastNameUnderLineView.backgroundColor = ([self.lastNameField.text isEqualToString:@""]) ? [UIColor redColor] : [UIColor lightGrayColor];
        self.lblError.alpha =  ([self.firstNameField.text isEqualToString:@""] || [self.lastNameField.text isEqualToString:@""]) ? 1 : 0;
    }];
}


@end
