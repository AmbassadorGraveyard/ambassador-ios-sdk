//
//  MyTabBarController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "MyTabBarController.h"

@implementation MyTabBarController

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor]};
}

@end
