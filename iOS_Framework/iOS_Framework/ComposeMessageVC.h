//
//  ComposeMessageVC.h
//  iOS_Framework
//
//  Created by Diplomat on 7/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeMessageVC : UIViewController

- (void)updateButtonWithCount:(NSUInteger)count;
- (id)initWithInitialMessage:(NSString *)string;
@property UIButton *sendButton;
@property UIButton *editButton;
@property NSString *defaultMessage;

// Allow dynamic adjustment of constraints
@property NSLayoutConstraint* sendbuttonHeight;
@property NSLayoutConstraint* width;

@end
