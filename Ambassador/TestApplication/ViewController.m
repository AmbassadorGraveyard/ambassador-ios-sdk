//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <Ambassador/Ambassador.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIView * loginView;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UIButton * btnDrawer;
@property (nonatomic, strong) IBOutlet UITextField * tfUsername;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIView * signInCrossbar;

@end

@implementation ViewController

- (void)viewDidLoad {
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
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.cornerRadius = 4;
    
    // Login Button
    self.btnLogin.layer.cornerRadius = 4;
}

@end
