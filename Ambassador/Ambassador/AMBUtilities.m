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

- (void)presentErrorAlertWithMessage:(NSString*)message forViewController:(UIViewController*)viewController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:NO];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    __weak AMBSendCompletionModal *weakVC = vc;
    vc.buttonAction = ^() {
        if (self.delegate && [self.delegate respondsToSelector:@selector(okayButtonClicked)]) {
            [weakVC dismissViewControllerAnimated:NO completion:^{
                [self.delegate okayButtonClicked];
            }];
        }
    };
    
    [viewController presentViewController:vc animated:YES completion:nil];
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
