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

- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message forViewController:(UIViewController*)viewController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:successful];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    __weak AMBSendCompletionModal *weakVC = vc;
    vc.buttonAction = ^() {
        [weakVC dismissViewControllerAnimated:NO completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(okayButtonClicked)]) { [self.delegate okayButtonClicked]; }
        }];
    };
    
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)showLoadingScreenWithText:(NSString*)loadingText forView:(UIView*)view {
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc] initWithFrame:view.frame];
    } else {
        self.loadingView.frame = view.frame;
    }
    
    UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = view.frame;
    [self.loadingView addSubview:blurView];
    UILabel *lblLoading = [[UILabel alloc] init];
    lblLoading.text = loadingText;
    [lblLoading sizeToFit];
    lblLoading.frame = CGRectMake(self.loadingView.frame.size.width/2 - lblLoading.frame.size.width/2, self.loadingView.frame.size.height/2 - lblLoading.frame.size.height/2, lblLoading.frame.size.width, lblLoading.frame.size.height);
    [self.loadingView addSubview:lblLoading];
    self.loadingView.alpha = 0;
    
    [view addSubview:self.loadingView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.loadingView.alpha = 1;
    }];
}

- (void)hideLoadingView {
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
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
