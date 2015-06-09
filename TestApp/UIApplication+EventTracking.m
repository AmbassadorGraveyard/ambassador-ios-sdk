//
//  UIApplication+EventTracking.m
//  iOSSDKtest
//
//  Created by Diplomat on 6/9/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "UIApplication+EventTracking.h"
#import <objc/runtime.h>

@implementation UIApplication (EventTracking)

+ (void)load {
    Class class = [self class];
    SEL originalSendAction = @selector(sendAction:to:from:forEvent:);
    SEL replacementSendAction = @selector(ambassador_sendAction:to:from:forEvent:);
    
    SEL originalSendEvent = @selector(sendEvent:);
    SEL replacementSendEvent = @selector(ambassador_sendEvent:);
    
    Method originalSendActionMethod = class_getInstanceMethod(class, originalSendAction);
    Method replacementSendActionMethod = class_getInstanceMethod(class, replacementSendAction);
    method_exchangeImplementations(originalSendActionMethod, replacementSendActionMethod);
    
    Method originalSendEventMethod = class_getInstanceMethod(class, originalSendEvent);
    Method replacementSendEventMethod = class_getInstanceMethod(class, replacementSendEvent);
    method_exchangeImplementations(originalSendEventMethod, replacementSendEventMethod);
}

- (BOOL)ambassador_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    NSString *selectorName = NSStringFromSelector(action);
    printf("\nSelector %s occurred.\n\n", [selectorName UTF8String]);
    return [self ambassador_sendAction:action to:target from:sender forEvent:event];
}

- (void)ambassador_sendEvent:(UIEvent *)event
{
    NSSet *touches = event.allTouches;
    UITouch *touch = [touches anyObject];
    if (touch.phase == UITouchPhaseEnded) {
        [self trackTouch:touch];
    }
    return [self ambassador_sendEvent:event];
    
}

- (UIViewController*)findViewController:(UIViewController*)viewController {
    if (viewController.presentedViewController)
    {
        return [self findViewController:viewController.presentedViewController];
    }
    else if ([viewController isKindOfClass:[UISplitViewController class]])
    {
        UISplitViewController* splitVC = (UISplitViewController*)viewController;
        if (splitVC.viewControllers.count > 0)
        {
            return [self findViewController:splitVC.viewControllers.lastObject];
        }
        else
        {
            return viewController;
        }
    }
    else if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navVC = (UINavigationController*)viewController;
        if (navVC.viewControllers.count > 0)
        {
            return [self findViewController:navVC.topViewController];
        }
        else
        {
            return viewController;
        }
    }
    else if ([viewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController* tabVC = (UITabBarController*)viewController;
        if (tabVC.viewControllers.count > 0)
        {
            return [self findViewController:tabVC.selectedViewController];
        }
        else
        {
            return viewController;
        }
    }
    else
    {
        return viewController;
    }
}

- (void)trackTouch:(UITouch*)touch {
    UIView* touchView = [[UIView alloc] init];
    touchView = touch.view;
    
    if ([touch.view isKindOfClass:[UINavigationBar class]])
    {
        NSLog(@"Navigation Bar clicked %p", touch.view);
    }
    else if ([touch.view.superview isKindOfClass:[UINavigationBar class]])
    {
        NSLog(@"Navigation Bar Button clicked %p", touch.view);
    }
    else
    {
        //Set rootController equal to the view controller containing the touched object
        UIViewController* rootController = [self findViewController:touch.window.rootViewController];
        NSString *label = [[NSString alloc] init];
        NSString *propertyName = [[NSString alloc] init];
        NSString *touchView = NSStringFromClass([touch.view class]);
        
        
        if ([touch.view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = [[UIButton alloc] init];
            btn = (UIButton *)touch.view;
            label = btn.titleLabel.text;
        }
        
        unsigned count;
        objc_property_t* properties = class_copyPropertyList([rootController class], &count);
        for (unsigned i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            NSString* name = [NSString stringWithUTF8String:property_getName(property)];
            if ([rootController respondsToSelector:NSSelectorFromString(name)])
            {
                if (touch.view == [rootController valueForKey:name])
                {
                    propertyName = name;
                    break;
                }
            }
        }
        free(properties);
        
        NSLog(@"Touch registered:\nProperty name: %@\nView Class: %@\nLabel: %@\nView Controller: %@", propertyName, touchView, label, NSStringFromClass([rootController class]));
    }
}

@end
