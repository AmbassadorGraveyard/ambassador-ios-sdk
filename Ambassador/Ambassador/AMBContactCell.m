//
//  ContactCell.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBContactCell.h"
#import "AMBThemeManager.h"

@interface AMBContactCell()

// IBOutlets
@property (nonatomic, weak) IBOutlet UILabel * name;
@property (nonatomic, weak) IBOutlet UILabel * value;
@property (nonatomic, weak) IBOutlet UIImageView * checkmarkView;
@property (nonatomic, weak) IBOutlet UIImageView * contactPhoto;
@property (nonatomic, weak) IBOutlet UIImageView * avatarImage;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * checkmarkConstraint;

@end

@implementation AMBContactCell


#pragma mark - Setup Functionality

- (void)setUpCellWithContact:(AMBContact*)contact isSelected:(BOOL)selected {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contact = contact;

    self.name.text = [contact fullName];
    self.name.font = [[AMBThemeManager sharedInstance] fontForKey:ContactTableNameTextFont];
    self.name.textColor = [[AMBThemeManager sharedInstance] colorForKey:ContactTableNameTextColor];
    self.value.text = [NSString stringWithFormat:@"%@ - %@", contact.label, contact.value];
    self.value.font = [[AMBThemeManager sharedInstance] fontForKey:ContactTableInfoTextFont];
    self.value.textColor = [[AMBThemeManager sharedInstance] colorForKey:ContactTableInfoTextColor];
    
    self.avatarImage.hidden = (contact.contactImage) ? YES : NO;
    if (!self.avatarImage.hidden) {
        self.avatarImage.image = [AMBValues imageFromBundleWithName:@"avatar" type:@"png" tintable:YES];
        self.avatarImage.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactAvatarColor];
    }
    
    self.contactPhoto.image = contact.contactImage;
    self.contactPhoto.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactAvatarBackgroundColor];
    self.contactPhoto.layer.cornerRadius = self.contactPhoto.frame.size.height/2;
    self.contactPhoto.layer.masksToBounds = YES;
    self.checkmarkView.image = [AMBValues imageFromBundleWithName:@"check" type:@"png" tintable:YES];
    self.checkmarkView.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactTableCheckMarkColor];
    self.checkmarkConstraint.constant = (selected) ? 16 : -(self.checkmarkView.frame.size.width);

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTriggered:)];
    [self addGestureRecognizer:longPress];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor cellSelectionGray];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}


#pragma mark - Helper Functions

- (void)longPressTriggered:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate longPressTriggeredForContact:self.contact];
    }
}


#pragma mark - UI Functions

- (void)animateCheckmarkIn {
    self.checkmarkConstraint.constant = 16;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    } completion:nil];
}

- (void)animateCheckmarkOut {
    self.checkmarkConstraint.constant = -self.checkmarkView.frame.size.width;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    } completion:nil];
}

- (void)setCellSelectionColor {
    UIView *colorView = [[UIView alloc] init];
    colorView.backgroundColor = [UIColor cellSelectionGray];
    self.selectedBackgroundView = colorView;
}

@end
