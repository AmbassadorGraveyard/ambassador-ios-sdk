//
//  LoadingScreen.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/31/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "LoadingScreen.h"

@implementation LoadingScreen

NSInteger loadingTag = 101;


+ (void)showLoadingScreenForView:(UIView*)view {
    // Creates a darkened view and adds tag for access later on
    UIView *dimmedView = [[UIView alloc] initWithFrame:view.frame];
    dimmedView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    dimmedView.tag = loadingTag;
    
    // Creates acitivy indicator aka spinner
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = view.center;
    [activity startAnimating];
    
    [dimmedView addSubview:activity];
    [view addSubview:dimmedView];
}

+ (void)hideLoadingScreenForView:(UIView*)view {
    // Searches all subview for the loadingView tag and removes that view
    for (UIView *subView in [view subviews]) {
        if (subView.tag == loadingTag) {
            [subView removeFromSuperview];
        }
    }
}

+ (void)rotateLoadingScreenForView:(UIView*)view {
    // Searches for loading view from tag and resets frames
    for (UIView *subView in [view subviews]) {
        if (subView.tag == loadingTag) {
            subView.frame = view.frame;
            
            // Re-centers activity indicator
            UIView *activityView = [subView subviews][0];
            activityView.center = subView.center;
        }
    }
}

@end
