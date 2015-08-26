//
//  NamePrompt.m
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "NamePrompt.h"
#import "Utilities.h"
#import "Constants.h"

@interface NamePrompt () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameError;
@property (weak, nonatomic) IBOutlet UILabel *lastNameError;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *viewTapped;
@property BOOL firstNameEdited;
@property BOOL lastNameEdited;
@end

@implementation NamePrompt

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [backButton setImage:imageFromBundleNamed(@"back.png") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
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
}

#pragma mark - Navigation
- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueSending:(UIButton *)sender
{
    if ([self textFieldIsValid:self.firstNameField.text] && [self textFieldIsValid:self.lastNameField.text])
    {
        NSMutableDictionary *information = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY]];
        DLog(@"This is what is stored before the name change %@", information)
        if (information)
        {
            information[@"first_name"] = self.firstNameField.text;
            information[@"last_name"] = self.lastNameField.text;
            
            [[NSUserDefaults standardUserDefaults] setObject:information forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
            DLog(@"Updating local cache %@", information);
        }
        [self.delegate sendSMSPressedWithName:self.firstNameField.text];
    }
   

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
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == self.firstNameField)
    {
        [self.lastNameField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.firstNameField) { self.firstNameEdited = YES; }
    if (textField == self.lastNameField) { self.lastNameEdited = YES; }
    return YES;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.firstNameField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.firstNameField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    if (!CGRectContainsPoint(aRect, self.lastNameField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.lastNameField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)removeKeyboard
{
    [self.view endEditing:YES];
}
@end
