//
//  CutomTabBarController.h
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutomTabBarController : UIViewController

@property NSMutableDictionary *UIPreferences;

- (id)initWithUIPreferences:(NSMutableDictionary *)preferences andSender:(id)sender;
@property id sender;

@end
