//
//  Utilities.m
//  iOS_Framework
//
//  Created by Diplomat on 7/15/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBUtilities.h"
#import "AMBSendCompletionModal.h"

@implementation AMBUtilities : NSObject

+ (AMBUtilities *)sharedInstance {
    static AMBUtilities* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBUtilities alloc] init]; });
    return _sharedInsance;
}

- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message withUniqueID:(NSString*)uniqueID forViewController:(UIViewController*)viewController shouldDismissVCImmediately:(BOOL)shouldDismiss {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:successful];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    __weak AMBSendCompletionModal *weakVC = vc;
    vc.buttonAction = ^() {
        [weakVC dismissViewControllerAnimated:NO completion:^{
            if (shouldDismiss) {
                [viewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(okayButtonClickedForUniqueID:)]) { [self.delegate okayButtonClickedForUniqueID:uniqueID]; }
            }
        }];
    };
    
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)showLoadingScreenForView:(UIView*)view {
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc] initWithFrame:view.frame];
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
    
@end

NSMutableDictionary* AMBparseQueryString(NSString *string)
{
    string = [[string componentsSeparatedByString:@"?"] lastObject];
    NSArray *variables = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *str in variables)
    {
        NSArray *pair = [str componentsSeparatedByString:@"="];
        [result setValue:[pair lastObject] forKey:[pair firstObject]];
    }
    
    DLog(@"%@", result);
    return result;
}

UIColor* AMBColorFromRGB(float r, float g, float b)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

UIImage* AMBimageFromBundleNamed(NSString *name, NSString *type)
{
    return [UIImage imageWithContentsOfFile:[AMBframeworkBundle() pathForResource:name ofType:type]];
}

void AMBsendAlert(BOOL success, NSString *message, UIViewController*presenter) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:success];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [presenter presentViewController:vc animated:YES completion:nil];
}

NSBundle* AMBframeworkBundle() {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Ambassador.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}


NSString* AMBStringValFromDictionary(NSMutableDictionary *d, NSString *key) {
    return (d[key] && d[key] != [NSNull null])? (NSString *)d[key] : @"";
}

NSArray *AMBArrayFromDicstionary(NSMutableDictionary *d, NSString *key) {
    return (d[key] && d[key] != [NSNull null])? (NSArray *)d[key] : @[];
}

NSString* AMBOptionalString(NSString *s) {
    return s? s :@"";
}
