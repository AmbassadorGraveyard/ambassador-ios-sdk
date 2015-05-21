//
//  GlobalMonitorUITapGestureRecognizer.m
//  ObjC
//
//  Created by Diplomat on 5/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "GlobalMonitorUITapGestureRecognizer.h"
#import "FingerPrintViewController.h"
#import <objc/runtime.h>
#import "CustomActivityViewOne.h"
#import "AMBFingerprint.h"

@import Foundation;


@interface GlobalMonitorUITapGestureRecognizer ()

@property BOOL enabledVisualizer;
@property NSMutableDictionary* eventTracking;
@property AMBFingerprint* fingerPrinter;

@end


@implementation GlobalMonitorUITapGestureRecognizer

#pragma mark - Initialization
- (id)init {
    return [self initWithConversionItems:[NSMutableDictionary dictionary] andReferAFriendItems:[NSMutableDictionary dictionary]];
}


- (id)initWithConversionItems:(NSMutableDictionary*)conversionItems andReferAFriendItems:(NSMutableDictionary*)referAFriendItems {
    if ([super initWithTarget:nil action:nil]) {
        //Default to not visualizing (in production)
        self.enabledVisualizer = false;
        
        //Register a fingerprint here
        self.fingerPrinter = [[AMBFingerprint alloc] init];
        [self.fingerPrinter registerFingerprint];
        
        //Set up tracking Dictionaries
        self.conversionItems = [[NSMutableDictionary alloc] init];
        self.conversionItems = conversionItems;
        self.referAFreindLauchItems = [[NSMutableDictionary alloc] init];
        self.referAFreindLauchItems = referAFriendItems;
        
        NSLog(@"DICTIONARY 1:%@\nDICTIONARY 2:%@", self.conversionItems, self.referAFreindLauchItems);
    }
    return self;
}


#pragma mark - API Functions

- (void)enableVisualizer {
    self.enabledVisualizer = NO;
}


#pragma mark - Touch Event Interception and Augmentation

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //All touches sent here
    for (UITouch* obj in touches.allObjects) {
        
        if (self.enabledVisualizer) {
            [self addBorderAnimationOnView:obj.view];
            [self takeScreenshotFromTouch:obj];
        }
        [self trackTouch:obj];
    }

    //NSLog(@"touchesBegn: %@", touches.allObjects);
    [super touchesBegan:touches withEvent:event];
}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    //NSLog(@"touchesMoved: %@", touches.allObjects);
//    [super touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    //NSLog(@"touchesEnded: %@", touches.allObjects);
//    [super touchesEnded:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//   // NSLog(@"touchesCancelled: %@", touches.allObjects);
//    [super touchesCancelled:touches withEvent:event];
//}


#pragma mark - Auxilary Touch Functions


- (void)takeScreenshotFromTouch:(UITouch*)touch {
    //necessary set up to get at the UIElement's rectangle
    UIView* view = [[UIView alloc] init];
    view = touch.view;
    
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
    UIImageWriteToSavedPhotosAlbum(image, self, NULL, NULL);
    
    NSData* data = UIImagePNGRepresentation(image);
    //Save the image at the designated path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:filePath contents:data attributes:nil]) {
        NSLog(@"Thumbnail Saved %@",filePath);
    } else {
        NSLog(@"Oops, file didn't save :(");
    }

}

//
//Function called in visualizer mode to highlight the object being touched
//to make touch events clearer
//
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


#pragma mark - Touch Tracking

- (void)trackTouch:(UITouch*)touch {
    UIView* touchView = [[UIView alloc] init];
    touchView = touch.view;
    UIViewController* rootController = [self findViewController:touch.window.rootViewController];

    if ([touch.view isKindOfClass:[UINavigationBar class]]) {
        NSLog(@"Navigation Bar clicked %p", touch.view);
        [self logEventWithName:@"__NavigationBar" touch:touch andViewController:touch.view.superview];
    } else if ([touch.view.superview isKindOfClass:[UINavigationBar class]]) {
        NSLog(@"Navigation Bar Button clicked %p", touch.view);
        [self logEventWithName:@"__Navigation Bar Button" touch:touch andViewController:touch.view.superview];
    } else if ([touch.view isKindOfClass:[UIButton class]]) {
        UIButton* button = (UIButton*)touch.view;
        NSLog(@"%@ button in %@ view controller", button.titleLabel.text, NSStringFromClass([rootController class]));
        [self logEventWithName:button.titleLabel.text touch:touch andViewController:touch.view];
        
        //Check if it's a conversion item
        if (self.conversionItems[button.titleLabel.text] &&
            [self.conversionItems[button.titleLabel.text] isEqualToString:NSStringFromClass([rootController class])]) {
            NSLog(@"Button conversion tracked");
        }
        
        //Check if it's a refer a friend trigger
        if (self.referAFreindLauchItems[button.titleLabel.text] &&
            [self.referAFreindLauchItems[button.titleLabel.text] isEqualToString:NSStringFromClass([rootController class])]) {
            [self testActiityViewControllerWithViewController:rootController];
        }
    } else {
        //Set rootController equal to the view controller containing the touched object
        
        
        //Has there been an event to track yet? If not, allocated for the tracking Dectionary
        if (!self.eventTracking) {
            self.eventTracking = [[NSMutableDictionary alloc] init];
        }
        
        //
        //In order to effectively track UI Elements that might get moved around in the
        //view hierarchy or positioned in different areas, the most effective ID is the
        //property name given by the developer. This function will start with the touched
        //object and find the root view controller, grab the navigation controller and the
        //VC associated with the view currently on screen to find the properties and fill the
        //elementsTracked array to be used for searching against.
        //
        //NOTE: Hasnt been thoughouly tested with all nested ViewControllers
        //
        unsigned count;
        objc_property_t* properties = class_copyPropertyList([rootController class], &count);
        for (unsigned i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString* name = [NSString stringWithUTF8String:property_getName(property)];
            if ([rootController respondsToSelector:NSSelectorFromString(name)]) {
                if (touch.view == [rootController valueForKey:name]) {
                    [self logEventWithName:name touch:touch andViewController:rootController];
                    if (self.conversionItems[name]) {
                        NSLog(@"tracked conversion");
                        [self testActiityViewControllerWithViewController:rootController];
                    }
                    break;
                }
            }
        }
        free(properties);
    }
}

//
//Takes a view controller (ideally the rootViewController) and recurses
//through the view heirerarchy to get the view controller most likely being
//displayed at the time of being called
//
- (UIViewController*)findViewController:(UIViewController*)viewController {
    //Logic is testing against view controllers that typically nest other
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
    } else {
        return viewController;
    }
}

- (void)logEventWithName:(NSString*)name touch:(UITouch*)touch andViewController:(id)viewController {
    //Make a log object for the eventTracking Dictionary
    NSMutableDictionary* log = [[NSMutableDictionary alloc] init];
    
    //Create the timestamp for the log object
    NSDate* now = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString* dateString = [dateFormatter stringFromDate:now];
    //
    //Either add a new item to the eventsTracking
    //dictionary (if it's the first time it was touched) or update the
    //count.
    //
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [log setObject:NSStringFromClass([touch.view class]) forKey:@"className"];
        //[log setObject:[NSNumber numberWithInt:1] forKey:@"count"];
        [log setObject:dateString forKey:@"timeStamp"];
        [log setObject:NSStringFromClass([viewController class]) forKey:@"viewController"];
        [log setObject:[defaults objectForKey:@"fingerprintJSON"] forKey:@"fingerprint"];
        //[self.eventTracking setValue:log forKey:name];
        NSLog(@"%@\t%@", log[@"className"], name);
}


#pragma mark - Sharing UI Elements

- (void)testActiityViewControllerWithViewController:(UIViewController*)viewController {
    NSString* messageText = @"blah blah blah link link stuff message blah";
    NSURL* messageUrl = [NSURL URLWithString:@"http://www.getambassador.com"];
    UIImage* messageImage = [UIImage imageNamed:@"slack-imgs.com.gif"];
    
    NSArray* activityItems = [NSArray arrayWithObjects:messageText, messageUrl, messageImage, nil];
    
    CustomActivityViewOne* activityVC = [[CustomActivityViewOne alloc] init];
    
    NSArray* excludedItems = [NSArray arrayWithObjects: UIActivityTypePrint,
                                                        UIActivityTypeCopyToPasteboard,
                                                        UIActivityTypeAssignToContact,
                                                        UIActivityTypeSaveToCameraRoll,
                                                        UIActivityTypeAddToReadingList,
                                                        UIActivityTypeAirDrop, nil];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:[NSArray arrayWithObject:activityVC]];
    
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    activityViewController.excludedActivityTypes = excludedItems;
    
    [viewController presentViewController:activityViewController animated:YES completion:nil];
}




//DEVELOPMENT TOOLS/////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark - Development/Debug Functions

- (void)listSubviewsOfView:(UIView *)view withSpacing:(NSString*)spacing {
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    if ([spacing isEqualToString:@""]) {
        NSLog(@"%p", view);
        spacing = [NSString stringWithFormat:@"    "];
    }
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    for (UIView *subview in subviews) {
        // Do what you want to do with the subview
        NSLog(@"%@%p", spacing, subview);
        // List the subviews of subview
        [self listSubviewsOfView:subview withSpacing:[NSString stringWithFormat:@"%@    ",spacing]];
    }
}

@end
