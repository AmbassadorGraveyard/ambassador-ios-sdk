//
//  AMBLinkCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBLinkCell.h"

@interface AMBLinkCell()

@property (nonatomic, strong) IBOutlet UIButton * btnLinkName;

@end


@implementation AMBLinkCell

- (void)setupCellWithLinkName:(NSString*)linkName tintColor:(UIColor*)tintColor {
    self.backgroundColor = [UIColor clearColor];
    self.btnLinkName.tintColor = tintColor;
    [self.btnLinkName setTitle:linkName forState:UIControlStateNormal];
}

@end
