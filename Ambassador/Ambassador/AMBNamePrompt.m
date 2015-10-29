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
#import "AMBAmbassadorNetworkManager.h"

@interface AMBNamePrompt () <UITextFieldDelegate, UIScrollViewDelegate>
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

@implementation AMBNamePrompt

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [backButton setImage:AMBimageFromBundleNamed(@"back", @"png") forState:UIControlStateNormal];
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
    
    self.scrollView.delegate = self;
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
        NSString *firstName = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastName = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
       
        AMBUpdateNameObject *nameUpdateObject = [[AMBUpdateNameObject alloc] initWithFirstName:firstName lastName:lastName email:[AmbassadorSDK sharedInstance].user.email];
        
        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:nameUpdateObject url:[AMBAmbassadorNetworkManager sendIdentifyUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (error) {
                if (data) {
                    DLog(@"Error Updating Names with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                } else {
                    DLog(@"Error Updating Names with Response Code - %li and Response - %@", (long)[httpResponse statusCode], @"No data available");
                }
                
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to update names.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
            } else {
                DLog(@"Successfully Updated Names with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                if ([AmbassadorSDK sharedInstance].user) {
                    [AmbassadorSDK sharedInstance].user.first_name = firstName;
                    [AmbassadorSDK sharedInstance].user.last_name = lastName;
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                [self.delegate namesUpdatedSuccessfully];
            }
        }];
        
        
//        [self.delegate sendSMSPressedWithFirstName:firstName lastName:lastName];
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
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    CGRect frame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, newFrame.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= newFrame.size.height;
    if (!CGRectContainsPoint(aRect, self.firstNameField.frame.origin) && [self.firstNameField isFirstResponder] ) {
        [self.scrollView scrollRectToVisible:self.firstNameField.frame animated:YES];
    }
    if (!CGRectContainsPoint(aRect, self.lastNameField.frame.origin) && [self.lastNameField isFirstResponder]) {
        [self.scrollView scrollRectToVisible:self.firstNameField.frame animated:YES];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
        [self.view endEditing:YES];
    }
}
@end
