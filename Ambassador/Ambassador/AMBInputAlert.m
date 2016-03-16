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
    [self.delegate actionButtonTapped];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextField Delegate

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

@end
