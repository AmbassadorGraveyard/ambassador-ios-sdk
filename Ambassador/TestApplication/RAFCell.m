//
//  RAFCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCell.h"

@implementation RAFCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpCellWithRafName:(NSString*)rafName {
    self.rafName.text = rafName;
    self.arrowImage.image = [self.arrowImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    self.arrowImage.tintColor = [UIColor colorWithRed:95/255 green:95/255 blue:95/255 alpha:1];
}

@end
