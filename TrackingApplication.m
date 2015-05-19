//
//  TrackingApplication.m
//  ObjC
//
//  Created by Diplomat on 5/19/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "TrackingApplication.h"
#import <objc/runtime.h>
#import "EventTrackingLog.h"

@interface TrackingApplication ()

@property NSMutableArray *trackedObjects;
@property NSMutableDictionary *eventTracking;

@end

@implementation TrackingApplication

- (void)sendEvent:(UIEvent *)event {
    NSLog(@"Event was caught: %@", event.description);
    NSMutableArray* touches = [NSMutableArray arrayWithArray:[[event allTouches] allObjects]];
    
    UITouch* touch = touches[0];
    [self addBorderAnimationOnView:touch.view];
    [self takeScreenshotFromView:touch.view];
    [self allPropertyNamesWithObject:touch];
    [self trackTouch:touch];
    
    [super sendEvent:event];
}
     
 - (void)trackTouch:(UITouch*)touch {
     //Set rootController equal to the view controller containing the touched object
     UIViewController* rootController = [self findViewController:touch.window.rootViewController];
     
     //Has there been an event to track yet? If not, allocated for the tracking Dectionary
     if (!self.eventTracking) {
         self.eventTracking = [[NSMutableDictionary alloc] init];
     }
     
     //Loop through the objects we are tracking in this view and test touch object
     //agaisnt it
     for (unsigned i = 0; i < self.trackedObjects.count; ++i) {
         if (touch.view == [rootController valueForKey:self.trackedObjects[i]]) {
             
             NSLog(@"%@", self.trackedObjects[i]);
             
             //Make a log object for the eventTracking Dictionary
             EventTrackingLog* log = [[EventTrackingLog alloc] init];
             
             //Create the timestamp for the log object
             NSDate* now = [NSDate date];
             NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
             log.timeStamp = [dateFormatter stringFromDate:now];
             
             //Either add a new item to the eventsTracking
             //dictionary (if it's the first time it was touched) or update the
             //count.
             if (self.eventTracking[self.trackedObjects[i]] == nil) {
                 log.count = [NSNumber numberWithInt:1];
             } else {
                 log = self.eventTracking[self.trackedObjects[i]];
                 int value = [log.count intValue];
                 log.count = [NSNumber numberWithInt:value + 1];
             }
             [self.eventTracking setValue:log forKey:self.trackedObjects[i]];
             return;
         }
     }
 }

- (void)addBorderAnimationOnView:(UIView*)view {
    view.layer.borderWidth = 1;
    CABasicAnimation* borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = (id)[UIColor orangeColor].CGColor;
    borderAnimation.toValue = (id)[UIColor clearColor].CGColor;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    borderAnimation.duration =  .75;//[CATransaction animationDuration];
    borderAnimation.timingFunction = [CATransaction animationTimingFunction];
    [view.layer addAnimation:borderAnimation forKey:@"animationTest"];
}

- (void)takeScreenshotFromView:(UIView*)view {
    //Beging getting context (checking for retina and scaling)
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    //Render and build the images
    //[touch.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData* data = UIImagePNGRepresentation(image);
    //Save the image at the designated path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:filePath contents:data attributes:nil]) {
        NSLog(@"File Saved at %@", filePath);
    } else {
        NSLog(@"Oops, file didn't save :(");
    }
}

- (UIViewController*)findViewController:(UIViewController*)viewController {
    //If if presented a view controller, it's not at the bottom of the hierarchy
    
    //The other logic is testing against view controllers that typically nest other
    //view controllers
    if (viewController.presentedViewController) {
        return [self findViewController:viewController.presentedViewController];
    } else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* splitVC = (UISplitViewController*)viewController;
        if (splitVC.viewControllers.count > 0) {
            return [self findViewController:splitVC.viewControllers.lastObject];
        } else {
            return viewController;
        }
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navVC = (UINavigationController*)viewController;
        if (navVC.viewControllers.count > 0) {
            return [self findViewController:navVC.topViewController];
        } else {
            return viewController;
        }
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabVC = (UITabBarController*)viewController;
        if (tabVC.viewControllers.count > 0) {
            return [self findViewController:tabVC.selectedViewController];
        } else {
            return viewController;
        }
    } else if ([viewController isKindOfClass:[UINavigationBar class]]) {
        return viewController;
    } else {
        return viewController;
    }
}

- (void)allPropertyNamesWithObject:(UITouch*)obj {
    //find the view controller where the touched object resides
    UIViewController* vc = [self findViewController:obj.window.rootViewController];
    
    self.trackedObjects = [NSMutableArray array];
    
    //This is the Objective-C runtime library being used to get the properties
    //on the view controller holding the touched obj and adds the to the array
    unsigned count;
    objc_property_t* properties = class_copyPropertyList([vc class], &count);
    for (unsigned i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString* name = [NSString stringWithUTF8String:property_getName(property)];
        [self.trackedObjects addObject:name];
    }
    NSLog(@"%@", self.trackedObjects);
    free(properties);
}

@end
