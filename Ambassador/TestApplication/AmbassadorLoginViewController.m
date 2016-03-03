//
//  AmbassadorLoginViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AmbassadorLoginViewController.h"

@interface AmbassadorLoginViewController()

@property (nonatomic, strong) IBOutlet UIView * loginMasterView;
@property (nonatomic, strong) IBOutlet UITextField * tfUserName;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UIButton * btnNoAccount;

@end


@implementation AmbassadorLoginViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
}


#pragma mark - UI Functions

- (void)setupUI {
    // Login View
    self.loginMasterView.layer.cornerRadius = 6;
    
    // Login button
    self.btnLogin.layer.cornerRadius = 6;
}

@end
