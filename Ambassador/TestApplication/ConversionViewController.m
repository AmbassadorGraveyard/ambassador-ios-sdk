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

@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UITextField * tfRefEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfRevAmt;
@property (nonatomic, strong) IBOutlet UITextField * tfCampID;
@property (nonatomic, strong) IBOutlet UISwitch * swtApproved;

@end

@implementation ConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
}


#pragma mark - IBAction


#pragma mark - UI Functions

- (void)setUpTheme {
    // Buttons
    self.btnSubmit.layer.cornerRadius = 5;
    
    // Views
    self.imgBGView.layer.cornerRadius = 5;
}


#pragma mark - Helper Functions

//- (void)registerConversion {
//    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
//    conversionParameters.mbsy_email = self.tfEmail.text;
//    conversionParameters.mbsy_campaign = @260;
//    conversionParameters.mbsy_revenue = @200;
//    conversionParameters.mbsy_custom1 = @"This is a conversion from the Ambassador iOS Test Application";
//    conversionParameters.mbsy_custom2 = [NSString stringWithFormat:@"Username registered = %@", self.tfUsername.text];
//    
//    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:YES completion:^(NSError *error) {
//        if (error) {
//            NSLog(@"Error registering install conversion - %@", error);
//        }
//    }];
//}
//
//- (BOOL)allowSignUp {
//    return (![self.tfEmail.text isEqualToString:@""] && ![self.tfPassword.text isEqualToString:@""] && ![self.tfUsername.text isEqualToString:@""]) ? YES : NO;
//}

@end
