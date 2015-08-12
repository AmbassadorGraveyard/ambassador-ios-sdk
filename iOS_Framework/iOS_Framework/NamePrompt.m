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
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation NamePrompt

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [backButton setImage:imageFromBundleNamed(@"back.png") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    // Do any additional setup after loading the view.
    self.continueButton.layer.cornerRadius = self.continueButton.frame.size.height/2;
    
    self.textField.backgroundColor = [UIColor clearColor];
    self.errorMessageLabel.hidden = YES;
    self.textField.textColor = [UIColor blackColor];
}

#pragma mark - Navigation
- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueSending:(UIButton *)sender
{
    if ([self textFieldIsValid:self.textField.text])
    {
        NSMutableDictionary *information = [[NSUserDefaults standardUserDefaults] objectForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
        DLog(@"This is what is stored before the name change %@", information)
        if (information)
        {
            NSArray *nameComponents = [self.textField.text componentsSeparatedByString:@" "];
            information[@"first_name"] = [nameComponents firstObject];
            information[@"last_name"] = [nameComponents lastObject];
            
            [[NSUserDefaults standardUserDefaults] setObject:information forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
            DLog(@"Updating local cache %@", information);
        }
        [self.delegate sendSMSPressedWithName:self.textField.text];
    }
   
    self.textField.delegate = self;
    [self updateErrorLabelForString:self.textField.text];
}

- (BOOL)textFieldIsValid:(NSString *)string
{
    NSArray *nameComponents = [string componentsSeparatedByString:@" "];
    return (nameComponents.count == 2) &&
    (![[nameComponents firstObject] isEqualToString:@""]) &&
    (![[nameComponents lastObject] isEqualToString:@""])? YES : NO;
}



#pragma mark - TextFieldDelegate
- (BOOL)textField:(nonnull UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
    NSMutableString *text = [NSMutableString stringWithString:self.textField.text];
    [text replaceCharactersInRange:range withString:string];
    [self updateErrorLabelForString:text];
    return YES;
}

- (void)updateErrorLabelForString:(NSString *)string
{
    if ([self textFieldIsValid:string])
    {
        self.errorMessageLabel.hidden = YES;
        self.textField.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.errorMessageLabel.hidden = NO;
        self.textField.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.25];

    }
}
@end
