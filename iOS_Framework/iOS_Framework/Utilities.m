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

UIImage* imageFromBundleNamed(NSString *name)
{
    return [UIImage imageNamed:name inBundle:[NSBundle bundleWithIdentifier:@"com.ambassador.Framework"] compatibleWithTraitCollection:nil];
}


UIViewController *topViewController(UIViewController *rootViewController)
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return topViewController(lastViewController);
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return topViewController(presentedViewController);
}

void sendAlert(BOOL success, NSString *message)
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleWithIdentifier:@"com.ambassador.Framework"]];
    SendCompletionModal *vc = (SendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    
    UIViewController *presenter = topViewController([UIApplication sharedApplication].keyWindow.rootViewController);
    
    vc.alertMessage = message;
    [vc shouldUseSuccessIcon:success];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [presenter presentViewController:vc animated:YES completion:nil];
}
