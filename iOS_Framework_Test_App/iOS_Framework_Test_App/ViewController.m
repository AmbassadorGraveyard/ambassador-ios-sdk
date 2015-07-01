//
//  ViewController.m
//  iOS_Framework_Test_App
//
//  Created by Diplomat on 6/23/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <iOS_Framework/iOS_Framework.h>

@interface ViewController ()

@property UILabel *message;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ConversionParameters *conversion = [[ConversionParameters alloc] init];
    conversion.mbsy_add_to_group_id = @134;
    conversion.mbsy_revenue = @1000;
    conversion.mbsy_campaign = @260;
    conversion.mbsy_first_name = @"test";
    conversion.mbsy_last_name = @"one";
    conversion.mbsy_email_new_ambassador = @YES;
    conversion.mbsy_uid = @"uiduiduiduiduiduiduid";
    conversion.mbsy_custom1 = @"custom111";
    conversion.mbsy_custom2 = @"custom222";
    conversion.mbsy_custom3 = @"custom333";
    conversion.mbsy_auto_create = @NO;
    conversion.mbsy_deactivate_new_ambassador = @YES;
    conversion.mbsy_transaction_uid = @"transuidtransuid";
    conversion.mbsy_add_to_group_id = @123456789;
    conversion.mbsy_event_data1 = @"eventdata1";
    conversion.mbsy_event_data2 = @"eventdata2";
    conversion.mbsy_event_data3 = @"eventdata3";
    conversion.mbsy_is_approved = @NO;
    
    conversion.mbsy_email = @"anonymous_test_1578@example.com";
    [Ambassador registerConversion:conversion];
    [Ambassador presentRAFFromViewController:self];
    
    [self functionToIgnoreDuringCodeReview];
}

- (void)functionToIgnoreDuringCodeReview
{
    self.message = [[UILabel alloc] init];
    self.message.text = @"Isn't this the sweetest app ever?!?";
    self.message.textAlignment = NSTextAlignmentCenter;
    self.message.backgroundColor = [UIColor orangeColor];
    self.message.translatesAutoresizingMaskIntoConstraints = NO;
    self.message.alpha = 1.0f;
    self.message.textColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.05
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.message.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
    [self.view addSubview:self.message];
    
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //
                     }
                     completion:^(BOOL finished){
                         self.message.backgroundColor = [UIColor blackColor];
                     }];
    
    [self.view addSubview:self.message];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.message attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.message attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.message attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
}

@end

