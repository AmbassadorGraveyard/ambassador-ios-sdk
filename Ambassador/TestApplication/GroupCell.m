//
//  GroupCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/20/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()

@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (nonatomic, weak) IBOutlet UILabel * lblId;
@property (nonatomic, weak) IBOutlet UIImageView * ivCheckmark;

@end


@implementation GroupCell

- (void)setUpCellWithGroup:(GroupObject *)group checkmarkVisible:(BOOL)visible {
    self.lblName.text = group.groupName;
    self.lblId.text = group.groupID;
    self.ivCheckmark.hidden = !visible;
}

@end
