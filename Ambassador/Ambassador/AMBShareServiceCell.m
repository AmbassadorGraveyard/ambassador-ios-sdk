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
    self.lblTitle.text = title;
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

@end
