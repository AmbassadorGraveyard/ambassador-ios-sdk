//
//  UIAlertController+CancelAlertController.m
//  Ambassador
//
//  Created by Jake Dunahee on 6/15/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "UIAlertController+CancelAlertController.h"

@implementation UIAlertController (CancelAlertController)

+ (UIAlertController *)cancelAlertWithTitle:(NSString *)title message:(NSString *)message cancelMessage:(NSString *)cancelMessage {
    return [UIAlertController cancelAlertWithTitle:title message:message cancelMessage:cancelMessage cancelAction:nil];
}

+ (UIAlertController *)cancelAlertWithTitle:(NSString *)title message:(NSString *)message cancelMessage:(NSString *)cancelMessage cancelAction:(void(^)())action {
    // Create alert
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Add cancel button
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelMessage style:UIAlertActionStyleCancel handler:action];
    [controller addAction:cancel];
    
    return controller;
}

@end
