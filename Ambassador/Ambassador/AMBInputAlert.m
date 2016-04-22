//
//  AMBCustomInputController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBInputAlert.h"
#import "AMBBulkShareHelper.h"
#import "AMBErrors.h"

@interface AMBInputAlert() <UITextFieldDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;
@property (nonatomic, strong) IBOutlet UILabel * lblMessage;
@property (nonatomic, strong) IBOutlet UITextField * tfInput;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) IBOutlet UIView * emailUnderline;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * masterViewCenterY;

// Private properties
@property (nonatomic, strong) NSString * titleText;
@property (nonatomic, strong) NSString * messageText;
@property (nonatomic, strong) NSString * actionButtonTitle;
@property (nonatomic, strong) NSString * placeHolderText;

@end


@implementation AMBInputAlert


#pragma mark - LifeCycle

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message placeHolder:(NSString*)placeHolder actionButton:(NSString*)actionButton {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"AMBCustomInput"];
    self.titleText = title;
    self.messageText = message;
    self.actionButtonTitle = actionButton;
    self.placeHolderText = placeHolder;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}

- (void)viewDidLoad {
    [self setUpUI];
    [self registerForKeyboardNotificaitons];
}


#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender {
    if ([[self.tfInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || ![self inputIsValid]) {
        [self showErrorLine];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate AMBInputAlertActionButtonTapped:self.tfInput.text];
    }
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self hideErrorLine];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Keyboard Delegate

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    [UIView animateWithDuration:0.3 animations:^{
        self.masterViewCenterY.constant = -70;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Resets the scrollview to original position
    [UIView animateWithDuration:0.3 animations:^{
        self.masterViewCenterY.constant = -50;
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - UI Functions

- (void)setUpUI {
    // Views
    self.masterView.layer.cornerRadius = 6;
    
    // Labels
    self.lblTitle.text = self.titleText;
    self.lblMessage.text = self.messageText;
    
    // TextFields
    [self.tfInput setPlaceholder:self.placeHolderText];
    
    // Buttons
    [self.btnAction setTitle:self.actionButtonTitle forState:UIControlStateNormal];
}

- (void)showErrorLine {
    [UIView animateWithDuration:0.2 animations:^{
        self.emailUnderline.backgroundColor = [UIColor errorRed];
    }];
}

- (void)hideErrorLine {
    [UIView animateWithDuration:0.2 animations:^{
        self.emailUnderline.backgroundColor = [UIColor darkGrayColor];
    }];
}

- (BOOL)inputIsValid {
    // Simplifies string to ignore spaces and case
    NSString *simplifiedPlaceHolderTxt = [[self.placeHolderText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    // Checks textField placeholder to see if its expecting an email address
    if ([simplifiedPlaceHolderTxt isEqualToString:@"email"] && ![AMBBulkShareHelper isValidEmail:self.tfInput.text]) {
        [AMBErrors errorSimpleInvalidEmail:self.tfInput.text];
        return NO;
    }
    
    return YES;
}

@end
