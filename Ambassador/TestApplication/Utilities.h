//
//  Utilities.h
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+ (void)setTabImageForViewController:(UIViewController*)viewController activeImageName:(NSString*)activeImg inactiveImageName:(NSString*)inactiveImg;

@end
