//
//  SelectedListTableCell.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "SelectedListTableCell.h"



#pragma mark - Local Constants
float const SELECTED_NAME_HEIGHT_CONSTANT = 20.0;
float const SELECTED_NAME_WIDTH_CONSTANT = -15.0;
float const SELECTED_NAME_LEFT_CONSTANT = 15.0;
#pragma mark -



@implementation SelectedListTableCell

#pragma mark - Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setUpName];
    }
    
    return self;
}

- (void)setUpName
{
    self.name = [[UILabel alloc] init];
    self.name.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.name];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.0
                                                                  constant:SELECTED_NAME_HEIGHT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:SELECTED_NAME_WIDTH_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:SELECTED_NAME_LEFT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
}

@end
