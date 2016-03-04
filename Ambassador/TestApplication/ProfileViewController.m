//
//  ProfileViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ProfileViewController.h"
#import "DefaultsHandler.h"
#import "ViewController.h"

@interface ProfileViewController()

@property (nonatomic, strong) IBOutlet UIImageView * ivAvatar;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UIButton * btnSignOut;
@property (nonatomic, strong) IBOutlet UIView * customNav;

@end


@implementation ProfileViewController


#pragma mark - LifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [self setupUI];
}


#pragma mark - UI Functions

- (void)setupUI {
    // Avatar
    self.ivAvatar.image = [DefaultsHandler getUserImage];
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
    self.ivAvatar.layer.borderColor = self.customNav.backgroundColor.CGColor;
    self.ivAvatar.layer.borderWidth = 2;
    
    // Label
    self.lblFullName.text = [DefaultsHandler getFullName];
    
    // Button
    self.btnSignOut.layer.cornerRadius = 6;
}


#pragma mark - IBActions

- (IBAction)signOut:(id)sender {
    [DefaultsHandler clearUserValues];
    [self.tabBarController setSelectedIndex:0];
    ViewController *initialController = [self.tabBarController viewControllers][0];
    [initialController checkForLogin];
}

@end
