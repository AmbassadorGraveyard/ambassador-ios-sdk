//
//  Utilities.m
//  iOS_Framework
//
//  Created by Diplomat on 7/15/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "Utilities.h"
#import "SendCompletionModal.h"

NSMutableDictionary* parseQueryString(NSString *string)
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

UIColor* ColorFromRGB(float r, float g, float b)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

UIImage* imageFromBundleNamed(NSString *name, NSString *type)
{
    return [UIImage imageWithContentsOfFile:[frameworkBundle() pathForResource:name ofType:type]];
}

void sendAlert(BOOL success, NSString *message, UIViewController *presenter)
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:frameworkBundle()];
    SendCompletionModal *vc = (SendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:success];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [presenter presentViewController:vc animated:YES completion:nil];
}

NSBundle* frameworkBundle() {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Ambassador.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

