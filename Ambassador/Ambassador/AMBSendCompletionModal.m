//
//  SendCompletionModal.m
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "AMBSendCompletionModal.h"
#import "AMBUtilities.h"
#import "AMBThemeManager.h"

@interface AMBSendCompletionModal ()

@property (nonatomic, strong) IBOutlet UIView *alertBox;
@property (nonatomic, strong) IBOutlet UIImageView *icon;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UILabel *message;

@end


@implementation AMBSendCompletionModal


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
}


#pragma mark - IBActions

- (IBAction)buttonPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClicked)]) {
        [self.delegate buttonClicked];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - UI Functionality

- (void)setUpTheme {
    // Button
    self.button.layer.cornerRadius = self.button.frame.size.height / 2;
    self.button.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:AlertButtonBackgroundColor];
    [self.button setTitleColor:[[AMBThemeManager sharedInstance] colorForKey:AlertButtonTextColor] forState:UIControlStateNormal];
    
    // Image
    NSString *imageName = self.successFlag ? @"successIcon" : @"failIcon";
    self.icon.image = [AMBValues imageFromBundleWithName:imageName type:@"png" tintable:NO];
    
    // Message
    self.message.text = self.alertMessage;
    
    // Master View
    self.alertBox.layer.cornerRadius = 6.0;
}

@end
