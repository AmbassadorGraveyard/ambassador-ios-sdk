//
//  AMBCustomInputController.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBInputAlert : UIViewController

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message placeHolder:(NSString*)placeHolder actionButton:(NSString*)actionButton;

@end
