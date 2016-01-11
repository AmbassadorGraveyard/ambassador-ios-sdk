//
//  Utilities.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)setTabImageForViewController:(UIViewController*)viewController activeImageName:(NSString*)activeImg inactiveImageName:(NSString*)inactiveImg {
    UITabBarItem *tabBarItem = [viewController.tabBarController.tabBar.items objectAtIndex:0];
    
    UIImage *unselectedImage = [UIImage imageNamed:inactiveImg];
//    [unselectedImage drawInRect:CGRectMake(0, 0, 20, 20)];
    UIImage *selectedImage = [UIImage imageNamed:activeImg];
    
    [tabBarItem setImage: [unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage: selectedImage];
}

@end
