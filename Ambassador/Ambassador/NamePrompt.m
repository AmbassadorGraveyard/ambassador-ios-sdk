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
    
    self.firstNameField.backgroundColor = [UIColor clearColor];
    self.lastNameField.backgroundColor = [UIColor clearColor];
    self.firstNameError.hidden = YES;
    self.firstNameError.hidden = YES;
    self.firstNameField.textColor = [UIColor blackColor];
    self.lastNameField.textColor = [UIColor blackColor];
}

#pragma mark - Navigation
- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueSending:(UIButton *)sender
{
    if ([self textFieldIsValid:self.firstNameField.text])
    {
        NSMutableDictionary *information = [[NSUserDefaults standardUserDefaults] objectForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
        DLog(@"This is what is stored before the name change %@", information)
        if (information)
        {
            NSArray *nameComponents = [self.firstNameField.text componentsSeparatedByString:@" "];
            information[@"first_name"] = [nameComponents firstObject];
            information[@"last_name"] = [nameComponents lastObject];
            
            [[NSUserDefaults standardUserDefaults] setObject:information forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
            DLog(@"Updating local cache %@", information);
        }
        [self.delegate sendSMSPressedWithName:self.firstNameField.text];
    }
   
    self.firstNameField.delegate = self;
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
    NSMutableString *text = [NSMutableString stringWithString:self.firstNameField.text];
    [text replaceCharactersInRange:range withString:string];
    [self updateErrorLabelForString:text];
    return YES;
}

- (void)updateErrorLabelForFirstNameString:(NSString *)fisrtString lastNameString:(NSString *)lastString
{
    if ([self textFieldIsValid:string])
    {
        self.firstNameError.hidden = YES;
        self.firstNameField.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.firstNameError.hidden = NO;
        self.firstNameField.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.25];

    }
}
@end
