//
//  SendCompletionModal.m
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "AMBSendCompletionModal.h"
#import "AMBUtilities.h"

@interface AMBSendCompletionModal ()

@property (weak, nonatomic) IBOutlet UIView *alertBox;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *message;

@property BOOL successFlag;

@end

@implementation AMBSendCompletionModal

- (void)shouldUseSuccessIcon:(BOOL)successful
{
    DLog();

    self.successFlag = successful;
    DLog(@"%i", self.successFlag);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog();
    self.message.text = self.alertMessage;
    
    [self setUpAlertBox];
    [self setUpIcon];
    [self setUpButton];
}

- (void)setUpAlertBox
{
    DLog();
    self.alertBox.layer.cornerRadius = 4.0;
}

- (void)setUpIcon
{
    DLog();
    NSString *imageName = self.successFlag? @"successIcon" : @"failIcon";
    DLog(@"%@", imageName);
    self.icon.image = AMBimageFromBundleNamed(imageName, @"png");
}

- (void)setUpButton
{
    DLog();
    self.button.layer.cornerRadius = self.button.frame.size.height / 2;
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    if (self.buttonAction)
    {
        self.buttonAction();
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
