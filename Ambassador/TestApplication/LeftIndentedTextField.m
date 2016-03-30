//
//  LeftIndentedTextField.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "LeftIndentedTextField.h"

@implementation LeftIndentedTextField

- (void)awakeFromNib {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
