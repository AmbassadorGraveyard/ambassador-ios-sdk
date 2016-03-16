//
//  AMBCustomInputController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBInputAlert.h"

@interface AMBInputAlert() <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;
@property (nonatomic, strong) IBOutlet UILabel * lblMessage;
@property (nonatomic, strong) IBOutlet UITextField * tfInput;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) IBOutlet UIView * emailUnderline;

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
}


#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender {
    if ([[self.tfInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
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
    [textField endEditing:YES];
    return YES;
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

@end
