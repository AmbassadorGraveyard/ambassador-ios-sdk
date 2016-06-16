//
//  UIAlertController+CancelAlertController.h
//  Ambassador
//
//  Created by Jake Dunahee on 6/15/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (CancelAlertController)

+ (UIAlertController *)cancelAlertWithTitle:(NSString *)title message:(NSString *)message cancelMessage:(NSString *)cancelMessage;
+ (UIAlertController *)cancelAlertWithTitle:(NSString *)title message:(NSString *)message cancelMessage:(NSString *)cancelMessage cancelAction:(void(^)())action;

@end
