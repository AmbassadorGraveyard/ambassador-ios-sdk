//
//  ProfileViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SettingsViewController.h"
#import "DefaultsHandler.h"
#import "ViewController.h"

@interface SettingsViewController()

@property (nonatomic, strong) IBOutlet UIImageView * ivAvatar;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UIButton * btnSignOut;
@property (nonatomic, strong) IBOutlet UIView * customNav;

@end


@implementation SettingsViewController


#pragma mark - LifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [self setupUI];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
}


#pragma mark - UI Functions

- (void)setupUI {
    // Avatar
    self.ivAvatar.image = [DefaultsHandler getUserImage];
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
    
    // Label
    self.lblFullName.text = [DefaultsHandler getFullName];
    
    // Button
    [self.btnSignOut setImage:[self.btnSignOut.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnSignOut.imageView.tintColor = self.btnSignOut.titleLabel.textColor;
    self.btnSignOut.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btnSignOut setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
}


#pragma mark - IBActions

- (IBAction)signOut:(id)sender {
    [DefaultsHandler clearUserValues];
    [self.tabBarController setSelectedIndex:0];
    ViewController *initialController = [self.tabBarController viewControllers][0];
    [initialController checkForLogin];
}

@end
