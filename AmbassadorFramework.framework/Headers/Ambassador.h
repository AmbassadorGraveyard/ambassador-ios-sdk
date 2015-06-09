//
//  Ambassador.h
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Ambassador : NSObject

#pragma mark - Retrieve shared instance
+ (Ambassador *)sharedInstance;

#pragma mark - API functions
+ (void)runWithAPIKey:(NSString *)key;
+ (void)registerConversionWithEmail:(NSString *)email;
+ (void)presentRAFFromViewController:(UIViewController *)viewController;

@end
