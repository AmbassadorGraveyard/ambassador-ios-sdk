//
//  Ambassador.h
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConversionParameters.h"

@interface Ambassador : NSObject

#pragma mark - Retrieve shared instance
+ (Ambassador *)sharedInstance;



#pragma mark - API functions
+ (void)runWithKey:(NSString *)key convertingOnLaunch:(ConversionParameters *)information;
+ (void)registerConversion:(ConversionParameters *)information;
+ (void)presentRAFFromViewController:(UIViewController *)viewController;

@end
