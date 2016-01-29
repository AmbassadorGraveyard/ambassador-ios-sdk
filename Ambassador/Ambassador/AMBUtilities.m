//
//  Utilities.m
//  iOS_Framework
//
//  Created by Diplomat on 7/15/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBUtilities.h"


@implementation AMBUtilities : NSObject 


#pragma mark - LifeCycle

+ (AMBUtilities *)sharedInstance {
    static AMBUtilities* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBUtilities alloc] init]; });
    return _sharedInsance;
}


#pragma mark - Custom Alert

- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message withUniqueID:(NSString*)uniqueID forViewController:(UIViewController*)viewController shouldDismissVCImmediately:(BOOL)shouldDismiss {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    vc.showSuccess = successful;
    vc.presentingVC = viewController;
    vc.shouldDismissPresentingVC = shouldDismiss;
    vc.uniqueIdentifier = uniqueID;
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [viewController presentViewController:vc animated:YES completion:nil];
}

// Custom Alert Delegate
- (void)buttonClickedWithPresentingVC:(UIViewController *)viewController shouldDismissPresentingVC:(BOOL)dismissPresenter uniqueID:(NSString *)uniqueID {
    if (dismissPresenter) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(okayButtonClickedForUniqueID:)]) { [self.delegate okayButtonClickedForUniqueID:uniqueID]; }
    }
}


#pragma mark - Loading Screen

- (void)showLoadingScreenForView:(UIView*)view {
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc] initWithFrame:view.frame];
        self.loadingView.isAccessibilityElement = YES;
        self.loadingView.accessibilityIdentifier = @"LoadingView";
        UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        self.blurView.frame = view.frame;
        self.animatingView = [[UIImageView alloc] initWithImage:[AMBValues imageFromBundleWithName:@"spinner" type:@"png" tintable:YES]];
        self.animatingView.tintColor = [UIColor whiteColor];
        [self.animatingView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    self.loadingView.frame = view.frame;
    self.blurView.frame = view.frame;
    
    if (![self.blurView isDescendantOfView:self.loadingView]) { [self.loadingView addSubview:self.blurView]; }
    if (![self.animatingView isDescendantOfView:self.loadingView]) { [self.loadingView addSubview:self.animatingView]; }

    self.animatingView.frame = CGRectMake(self.loadingView.frame.size.width/2 - 50, self.loadingView.frame.size.height - (self.loadingView.frame.size.height * .75), 100, 100);
    
    [view addSubview:self.loadingView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.loadingView.alpha = 1;
    } completion:^(BOOL finished) {
        [self startSpinner];
    }];
}

- (void)startSpinner {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1.5];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100;
    
    [self.animatingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)hideLoadingView {
    if (self.loadingView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.loadingView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.loadingView removeFromSuperview];
        }];
    }
}

- (void)rotateLoadingView:(UIView*)view orientation:(UIInterfaceOrientation)orientation {
    CGRect newFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);

    // LANDSCAPE - Spinner set center, PORTRAIT - Spinner center horizontally center but is higher vertically
    self.animatingView.frame = (UIInterfaceOrientationIsPortrait(orientation)) ?
    CGRectMake(newFrame.size.width/2 - 50, newFrame.size.height - (newFrame.size.height * .75), 100, 100) :
    CGRectMake(newFrame.size.width/2 - 50, newFrame.size.height/2 - 50, 100, 100);

    self.loadingView.frame = newFrame;
    self.blurView.frame = newFrame;
}


#pragma mark - FadeView 

- (void)addFadeToView:(UIView*)view {
    if (!self.fadeView) {
        self.fadeView = [[UIView alloc] init];
        self.fadeView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        self.fadeView.alpha = 0;
    }
    
    self.fadeView.frame = view.frame;
    self.fadeView.alpha = 0;
    [view addSubview:self.fadeView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.fadeView.alpha = 1;
    }];
}

- (void)removeFadeFromView {
    [UIView animateWithDuration:0.3 animations:^{
        self.fadeView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.fadeView removeFromSuperview];
    }];
}

- (void)rotateFadeForView:(UIView*)view {
    if (self.fadeView && [self.fadeView isDescendantOfView:view]) {
        self.fadeView.frame = view.frame;
        [view bringSubviewToFront:self.fadeView];
    }
}


#pragma mark - Misc Class Functions

+ (NSString*)createRequestID {
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%f", timeInMiliseconds];
}

+ (BOOL)colorIsDark:(UIColor*)color {
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    double redValue = components[0];
    CGFloat greenValue = components[1];
    CGFloat blueValue = components[2];
    CGFloat darkness = 1 - (299 * redValue + 587 * greenValue + 114 * blueValue)/1000;

    return (darkness < 0.5) ? NO : YES;
}

+ (BOOL)isSuccessfulStatusCode:(NSInteger)statusCode {
    if (statusCode >= (NSInteger)200 && statusCode <= (NSInteger)299) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSDictionary*)dictionaryFromQueryString:(NSString*)queryString {
    queryString = [[queryString componentsSeparatedByString:@"?"] lastObject];
    NSArray *variables = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    for (NSString *str in variables) {
        NSArray *pair = [str componentsSeparatedByString:@"="];
        [result setValue:[pair lastObject] forKey:[pair firstObject]];
    }
    
    return result;
}
    
@end