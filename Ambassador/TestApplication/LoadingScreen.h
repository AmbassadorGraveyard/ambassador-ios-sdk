//
//  LoadingScreen.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/31/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoadingScreen : NSObject

+ (void)showLoadingScreenForView:(UIView*)view;
+ (void)hideLoadingScreenForView:(UIView*)view;
+ (void)rotateLoadingScreenForView:(UIView*)view;

@end
