//
//  SignUpViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ConversionViewController.h"
#import <Ambassador/Ambassador.h>

@interface ConversionViewController ()

@property (nonatomic, strong) IBOutlet UIView * loginView;
@property (nonatomic, strong) IBOutlet UIButton * btnSignUp;
@property (nonatomic, strong) IBOutlet UIButton * btnDrawer;
@property (nonatomic, strong) IBOutlet UITextField * tfEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfUsername;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar2;

@end

@implementation ConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
}


#pragma mark - IBAction

- (IBAction)signUpTapped:(id)sender {
    [self.view endEditing:YES];
    if ([self allowSignUp]) {
        [self registerConversion];
    } else {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"Cannot log in" message:@"All fields must be filled out before signing in" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [blankAlert show];
    }
}

- (void)setUpTheme {
    // Login View
    self.loginView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.signInCrossbar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.signInCrossbar2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.cornerRadius = 4;
    
    // Login Button
    self.btnSignUp.layer.cornerRadius = 4;
}

- (void)registerConversion {
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = self.tfEmail.text;
    conversionParameters.mbsy_campaign = @260;
    conversionParameters.mbsy_revenue = @200;
    conversionParameters.mbsy_custom1 = @"This is a conversion from the Ambassador iOS Test Application";
    conversionParameters.mbsy_custom2 = [NSString stringWithFormat:@"Username registered = %@", self.tfUsername.text];
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:YES completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error registering install conversion - %@", error);
        }
    }];
}

- (BOOL)allowSignUp {
    return (![self.tfEmail.text isEqualToString:@""] && ![self.tfPassword.text isEqualToString:@""] && ![self.tfUsername.text isEqualToString:@""]) ? YES : NO;
}

@end
