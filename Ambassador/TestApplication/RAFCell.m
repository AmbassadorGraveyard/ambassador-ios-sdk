//
//  RAFCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCell.h"

@implementation RAFCell

- (void)setUpCellWithRafName:(NSString*)rafName {
    self.rafName.text = rafName;
    [self.btnExport setImage:[self.btnExport.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnExport.tintColor = [UIColor lightGrayColor];
}

@end
