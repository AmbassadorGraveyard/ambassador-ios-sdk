//
//  LeftIndentedTextField.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "LeftIndentedTextField.h"
#import "UIColor+AMBColorValues.h"

@implementation LeftIndentedTextField

- (void)awakeFromNib {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.tintColor = [UIColor colorFromHexString:@"3C97D3"];
}

@end
