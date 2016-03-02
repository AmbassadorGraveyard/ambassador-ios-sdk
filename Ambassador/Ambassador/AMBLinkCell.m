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
@property (nonatomic) NSInteger rowNumber;

@end


@implementation AMBLinkCell


#pragma mark - LifeCycle

- (void)setupCellWithLinkName:(NSString*)linkName tintColor:(UIColor*)tintColor rowNum:(NSInteger)rowNum {
    self.backgroundColor = [UIColor clearColor];
    self.btnLinkName.tintColor = tintColor;
    [self.btnLinkName setTitle:linkName forState:UIControlStateNormal];
    self.rowNumber = rowNum;
}


#pragma mark - IBActions

- (IBAction)buttonPressed:(id)sender {
    [self.delegate buttonPressedAtIndex:self.rowNumber];
}

@end
