//
//  ContactSelectionViewController.h
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSelectionViewController : UIViewController

@property NSMutableArray *data;
@property NSString *defaultMessage;
- (id)initWithInitialMessage:(NSString *)string;

@end
