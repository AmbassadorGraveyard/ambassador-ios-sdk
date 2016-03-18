//
//  SignUpViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ConversionViewController.h"
#import <Ambassador/Ambassador.h>
#import "Validator.h"

@interface ConversionViewController ()

@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UITextField * tfRefEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfRevAmt;
@property (nonatomic, strong) IBOutlet UITextField * tfCampID;
@property (nonatomic, strong) IBOutlet UISwitch * swtApproved;

@end

@implementation ConversionViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.title = @"Conversion";
    [self addConversionExportButton];
}


#pragma mark - IBAction

- (IBAction)submitTapped:(id)sender {
    [self.view endEditing:YES];
    [self performConversionAction];
}


#pragma mark - UI Functions

- (void)setUpTheme {
    // Buttons
    self.btnSubmit.layer.cornerRadius = 5;
    
    // Views
    self.imgBGView.layer.cornerRadius = 5;
    
    // TextFields
//    [self setTextFieldValues];
}

- (void)addConversionExportButton {
    UIBarButtonItem *btnExport = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exportIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(exportConversionCode)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnExport;
}

- (void)setTextFieldValues {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    
    for (UITextField *textField in [self.view subviews]) {
        if ([textField isKindOfClass:[UITextField class]]) {
            textField.leftView = paddingView;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.tintColor = self.btnSubmit.backgroundColor;
        }
    }
}


#pragma mark - Helper Functions

- (void)registerConversion {
    // Creates a formatter to get an NSNumber from a String
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber *campIDNumber = [formatter numberFromString:self.tfCampID.text];
    NSNumber *revAmt = [formatter numberFromString:self.tfRevAmt.text];
    BOOL shouldAutoApprove = [self.swtApproved isOn];
    
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = self.tfRefEmail.text;
    conversionParameters.mbsy_campaign = campIDNumber;
    conversionParameters.mbsy_revenue = revAmt;
    conversionParameters.mbsy_is_approved = [NSNumber numberWithBool:shouldAutoApprove];
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error registering conversion - %@", error);
        } else {
            NSLog(@"Conversion registered successfully!");
        }
    }];
}

- (void)performConversionAction {
    if (![self invalidFields]) {
        [self registerConversion];
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Great!" message:@"You have successfully registered a conversion." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [successAlert show];
    }
}

- (void)exportConversionCode {
    
}

- (BOOL)invalidFields {
    if ([Validator emptyString:self.tfRefEmail.text] || [Validator emptyString:self.tfRevAmt.text] || [Validator emptyString:self.tfCampID.text]) {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"No fields can be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [blankAlert show];
        
        return YES;
    }
    
    if (![Validator isValidEmail:self.tfRefEmail.text]) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address."]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        return YES;
    }
    
    return NO;
}

@end
