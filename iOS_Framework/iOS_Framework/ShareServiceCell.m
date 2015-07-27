//
//  ShareServiceCell.m
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ShareServiceCell.h"
#import "Utilities.h"
#import "Constants.h"



#pragma mark - Local Constants
float const LOGO_BACKGROUND_BORDER_WIDTH = 2.0;
float const LOGO_BACKGROUND_CORNER_RADIUS = 2.0;
float const LOGO_BACKGROUND_HEIGHT = 60.0;
float const LOGO_BACKGROUND_WIDTH = 60.0;
float const LOGO_HEIGHT = 20.0;
float const TITLE_HEIGHT = 20.0;
float const TITILE_TOP_PADDING = 10.0;
#pragma mark -



@implementation ShareServiceCell

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    [self setUpLogoBackground];
    [self setUpLogo];
    [self setUpTitle];
}

- (void)setUpLogoBackground
{
    // Initialize properties
    self.logoBackground = [[UIView alloc] init];
    self.logoBackground.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoBackground.layer.borderWidth = LOGO_BACKGROUND_BORDER_WIDTH;
    self.logoBackground.layer.cornerRadius = LOGO_BACKGROUND_CORNER_RADIUS;
    self.logoBackground.clipsToBounds = YES;
    
    // Add to view hierarchy
    [self.contentView addSubview:self.logoBackground];
    
    // AutoLayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.logoBackground
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.0
                                     constant:LOGO_BACKGROUND_HEIGHT]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.logoBackground
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:0.0
                                     constant:LOGO_BACKGROUND_WIDTH]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.logoBackground
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.logoBackground
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:0.0]];
}

- (void)setUpLogo
{
    // Initialize properties
    self.logo = [[UIImageView alloc] init];
    self.logo.translatesAutoresizingMaskIntoConstraints = NO;
    self.logo.contentMode = UIViewContentModeScaleAspectFit;
    
    // Add to view hierarchy
    [self.logoBackground addSubview:self.logo];
    
    // AutoLayout constraints
    [self.logoBackground addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.logo
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.logoBackground
                                        attribute:NSLayoutAttributeHeight
                                        multiplier:0.0
                                        constant:LOGO_HEIGHT]];
    [self.logoBackground addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.logo
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.logoBackground
                                        attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0
                                        constant:0.0]];
    [self.logoBackground addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.logo
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.logoBackground
                                        attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                        constant:0.0]];
}

- (void)setUpTitle
{
    // Initialize properties
    self.title = [[UILabel alloc] init];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.font = DEFAULT_FONT_SMALL();
    self.title.textAlignment = NSTextAlignmentCenter;
    
    // Add to view hierarchy
    [self.contentView addSubview:self.title];
    
    // AutoLayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.0
                                     constant:TITLE_HEIGHT]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.logoBackground
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0
                                     constant:TITILE_TOP_PADDING]];
}

@end
