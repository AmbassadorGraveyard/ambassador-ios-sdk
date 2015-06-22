//
//  Ambassador.h
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Ambassador : NSObject

#pragma mark - Retrieve shared instance
+ (Ambassador *)sharedInstance;



#pragma mark - API functions
+ (void)runWithKey:(NSString *)key convertingOnLaunch:(NSDictionary *)information;
+ (void)registerConversion:(NSDictionary *)information;
+ (void)presentRAFFromViewController:(UIViewController *)viewController;

@end
