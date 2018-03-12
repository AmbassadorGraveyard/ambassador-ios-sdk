//
//  MyTabBarController.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Ambassador/Ambassador.h>

@interface MyTabBarController : UITabBarController <AMBWelcomeScreenDelegate>

- (void)checkForLogin;

@end
