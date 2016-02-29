//
//  AMBWelcomeScreenViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenViewController.h"

@interface AMBWelcomeScreenViewController()

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivProfilePic;
@property (nonatomic, strong) IBOutlet UILabel * lblReferred;
@property (nonatomic, strong) IBOutlet UILabel * lblDescription;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * buttonHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * masterViewTop;

@end


@implementation AMBWelcomeScreenViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTheme];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.dogbehaviourltd.co.uk/userimages/Bulldog_Puppy_Posed_On_White_Background.jpg"]];
    self.ivProfilePic.image = [UIImage imageWithData:imageData];
    self.masterViewTop.constant = -(self.masterViewTop.constant + self.masterView.frame.size.height);
}

- (void)viewDidLayoutSubviews {
    if (self.masterViewTop.constant < 30) {
        self.masterViewTop.constant = 30;
        [UIView animateKeyframesWithDuration:0.6 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                [self.view layoutIfNeeded];
            }];
        } completion:nil];
    }
}


#pragma mark - IBActions

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UI Functions

- (void)setTheme {
    // Master View
    self.masterView.layer.cornerRadius = 6;
    
    // Image View
    self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.height/2;
    self.ivProfilePic.layer.borderColor = self.btnAction.backgroundColor.CGColor;
    self.ivProfilePic.layer.borderWidth = 2;
}

@end
