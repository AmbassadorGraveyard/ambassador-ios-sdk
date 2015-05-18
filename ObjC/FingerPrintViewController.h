
//
//  FingerPrintViewController.h
//  ObjC
//
//  Created by Diplomat on 5/12/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FingerPrintViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *toggle;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

@end
