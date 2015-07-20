//
//  ContactListTableCell.m
//  ipadcontacts
//
//  Created by Diplomat on 7/9/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ContactListTableCell.h"



#pragma mark - Local Constants
float const NAME_HEIGHT_CONSTANT = 20.0;
float const NAME_WIDTH_CONSTANT = -15.0;
float const NAME_LEFT_CONSTANT = 15.0;

float const VALUE_HEIGHT_CONSTANT = 20.0;
float const VALUE_WIDTH_CONSTANT = -15.0;
float const VALUE_LEFT_CONSTANT = 15.0;
#pragma mark -



@implementation ContactListTableCell

#pragma mark - Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setUp];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)setUp
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setUpName];
    [self setUpValue];
}

- (void)setUpName
{
    // Initialize properties
    self.name = [[UILabel alloc] init];
    self.name.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add to view hierarchy
    [self.contentView addSubview:self.name];
    
    // Add autolayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.0
                                                                  constant:NAME_HEIGHT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:NAME_WIDTH_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:NAME_LEFT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.name
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
}


- (void)setUpValue
{
    // Initialize properties
    self.value = [[UILabel alloc] init];
    self.value.translatesAutoresizingMaskIntoConstraints = NO;
    self.value.textColor = [UIColor lightGrayColor];
    
    // Add to view hierarchy
    [self.contentView addSubview:self.value];
    
    // Add autolayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.value
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.0
                                                                  constant:VALUE_HEIGHT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.value
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:VALUE_WIDTH_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.value
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:VALUE_LEFT_CONSTANT]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.value
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
}

@end
