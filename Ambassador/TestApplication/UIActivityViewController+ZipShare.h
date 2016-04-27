//
//  UIActivityViewController+ZipShare.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityViewController (ZipShare)

+ (void)shareZip:(NSURL *)zip withMessage:(NSString *)message subject:(NSString *)subject forPresenter:(UIViewController *)presenter;
+ (void)shareZip:(NSURL *)zip withMessage:(NSString *)message subject:(NSString *)subject forPresenter:(UIViewController *)presenter withCompletion:(UIActivityViewControllerCompletionHandler)completion;

@end
