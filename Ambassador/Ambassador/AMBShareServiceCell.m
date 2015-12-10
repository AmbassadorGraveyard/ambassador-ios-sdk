//
//  ShareServiceCell.m
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBShareServiceCell.h"

@interface AMBShareServiceCell ()

// Local properties
@property (nonatomic, strong) IBOutlet UIImageView * ivLogo;
@property (nonatomic, strong) IBOutlet UIView * logoBackground;
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;

@end


@implementation AMBShareServiceCell

- (void)setUpCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon {
    self.isAccessibilityElement = YES;
    self.lblTitle.text = title;
    self.logoBackground.layer.borderWidth = 0;
    self.logoBackground.backgroundColor = backgroundColor;
    self.logoBackground.layer.cornerRadius = 2;
    self.ivLogo.image = imageIcon;
}

- (void)setupBorderCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon borderColor:(UIColor*)borderColor {
    self.lblTitle.text = title;
    self.logoBackground.backgroundColor = backgroundColor;
    self.logoBackground.layer.borderColor = borderColor.CGColor;
    self.logoBackground.layer.borderWidth = 1.5;
    self.logoBackground.layer.cornerRadius = 2;
    self.ivLogo.image = imageIcon;
}

- (void)setUpCellWithCellType:(SocialShareTypes)cellType {
    self.cellType = cellType;
    switch (cellType) {
        case Facebook:
            [self setUpCellWithTitle:@"Facebook" backgroundColor:[UIColor faceBookBlue] icon:[AMBValues imageFromBundleWithName:@"facebook" type:@"png" tintable:NO]];
            break;
        case Twitter:
            [self setUpCellWithTitle:@"Twitter" backgroundColor:[UIColor twitterBlue] icon:[AMBValues imageFromBundleWithName:@"twitter" type:@"png" tintable:NO]];
            break;
        case LinkedIn:
            [self setUpCellWithTitle:@"LinkedIn" backgroundColor:[UIColor linkedInBlue] icon:[AMBValues imageFromBundleWithName:@"linkedin" type:@"png" tintable:NO]];
            break;
        case SMS:
            [self setupBorderCellWithTitle:@"SMS" backgroundColor:[UIColor clearColor] icon:[AMBValues imageFromBundleWithName:@"sms" type:@"png" tintable:NO] borderColor:[UIColor lightGrayColor]];
            break;
        case Email:
            [self setupBorderCellWithTitle:@"Email" backgroundColor:[UIColor clearColor] icon:[AMBValues imageFromBundleWithName:@"email" type:@"png" tintable:NO] borderColor:[UIColor lightGrayColor]];
            break;
        case None:
            [self setupBorderCellWithTitle:@"Unavailable" backgroundColor:[UIColor clearColor] icon:[AMBValues imageFromBundleWithName:@"failIcon" type:@"png" tintable:NO] borderColor:[UIColor lightGrayColor]];
        default:
            break;
    }
}

@end
