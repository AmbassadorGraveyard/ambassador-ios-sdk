
//
//  ProfileViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SettingsViewController.h"
#import "DefaultsHandler.h"
#import "MyTabBarController.h"

@interface SettingsViewController()

@property (nonatomic, strong) IBOutlet UIImageView * ivAvatar;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UILabel * lblSDKToken;
@property (nonatomic, strong) IBOutlet UILabel * lblUniversalID;
@property (nonatomic, strong) IBOutlet UIButton * btnSignOut;
@property (nonatomic, strong) IBOutlet UIButton * btnCopyToken;
@property (nonatomic, strong) IBOutlet UIButton * btnCopyID;
@property (nonatomic, strong) IBOutlet UIView * tokenBackgroundView;
@property (nonatomic, strong) IBOutlet UIView * idBackgroundView;

@property (nonatomic, strong) UILabel * lblCopied;
@property (nonatomic) BOOL lblCopiedShowing;

@end


@implementation SettingsViewController

NSInteger copiedHgt = 45;
NSInteger copiedWdt = 170;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setUpdateItems];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.lblCopied) {
        self.lblCopied = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - copiedWdt/2, self.view.frame.size.height, copiedWdt, copiedHgt)];
        self.lblCopied.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        self.lblCopied.text = @"Copied!";
        self.lblCopied.clipsToBounds = YES;
        self.lblCopied.textAlignment = NSTextAlignmentCenter;
        self.lblCopied.textColor = [UIColor whiteColor];
        self.lblCopied.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        self.lblCopied.layer.cornerRadius = copiedHgt/2;
        
        [self.view addSubview:self.lblCopied];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
    self.lblCopied.frame = CGRectMake(self.view.frame.size.width/2 - copiedWdt/2, self.view.frame.size.height, copiedWdt, copiedHgt);
}


#pragma mark - UI Functions

- (void)setupUI {
    // Avatar
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
    self.ivAvatar.image = [DefaultsHandler getUserImage];
    
    // Button
    [self.btnSignOut setImage:[self.btnSignOut.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnSignOut.imageView.tintColor = self.btnSignOut.titleLabel.textColor;
    self.btnSignOut.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btnSignOut setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
}

- (void)setUpdateItems {
    // Nav Bar
    self.tabBarController.title = @"Settings";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    
    // Avatar
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.height/2;
    self.ivAvatar.image = [DefaultsHandler getUserImage];
    
    // Copied label position
    self.lblCopied.frame = CGRectMake(self.view.frame.size.width/2 - copiedWdt/2, self.view.frame.size.height, copiedWdt, copiedHgt);
    
    // Label
    self.lblFullName.text = [DefaultsHandler getFullName];
    self.lblSDKToken.text = [DefaultsHandler getSDKToken];
    self.lblUniversalID.text = [DefaultsHandler getUniversalID];
}

- (void)showCopiedLabel {
    if (!self.lblCopiedShowing) {
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.3 animations:^{
                self.lblCopied.frame = CGRectMake(self.view.frame.size.width/2 - copiedWdt/2, self.lblCopied.frame.origin.y - 80, copiedWdt, copiedHgt);
                self.lblCopiedShowing = YES;
            }];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.lblCopied.frame = CGRectMake(self.view.frame.size.width/2 - copiedWdt/2, self.view.frame.size.height, copiedWdt, copiedHgt);
            } completion:^(BOOL finished) {
                self.lblCopiedShowing = NO;
            }];
        }];
    }
}


#pragma mark - IBActions

- (IBAction)signOut:(id)sender {
    [DefaultsHandler clearUserValues];
    [self.tabBarController setSelectedIndex:0];
    MyTabBarController *controller = (MyTabBarController*)self.tabBarController;
    [controller checkForLogin];
}

- (IBAction)copyTokenToClipboard:(id)sender {
    [self performClipboardCopyForLabel:self.lblSDKToken];
}

- (IBAction)copyIDToClipboard:(id)sender {
    [self performClipboardCopyForLabel:self.lblUniversalID];
}


#pragma mark - Helper Functions

- (void)performClipboardCopyForLabel:(UILabel*)label {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:label.text];
    
    [self showCopiedLabel];
}

@end
