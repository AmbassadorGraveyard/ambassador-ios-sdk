//
//  SignUpViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SignUpViewController.h"
#import "Utilities.h"

@interface SignUpViewController ()

@property (nonatomic, strong) IBOutlet UIView * loginView;
@property (nonatomic, strong) IBOutlet UIButton * btnSignUp;
@property (nonatomic, strong) IBOutlet UIButton * btnDrawer;
@property (nonatomic, strong) IBOutlet UITextField * tfEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfUsername;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar2;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
