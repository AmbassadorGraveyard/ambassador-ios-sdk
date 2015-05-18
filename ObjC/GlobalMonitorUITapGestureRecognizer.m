//
//  GlobalMonitorUITapGestureRecognizer.m
//  ObjC
//
//  Created by Diplomat on 5/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "GlobalMonitorUITapGestureRecognizer.h"
#import "FingerPrintViewController.h"

@interface GlobalMonitorUITapGestureRecognizer ()

@property NSMutableArray* trackedObjects;
@property BOOL enabledVisualizer;

@end

@implementation GlobalMonitorUITapGestureRecognizer

- (id) init {
    if ([super init]) {
        self.enabledVisualizer = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventHandler) name:@"UIWindowDidBecomeVisibleNotification" object:nil];
    }
    return self;
}

- (void)eventHandler {
    NSLog(@"Event Handled");
}

- (void) enableVisualizer {
    self.enabledVisualizer = YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //All touches sent here
    for (UITouch* obj in touches.allObjects) {
//        NSLog(@"Object touched:\n\tOrigin x: %ld\n\tOrigin y: %ld\n\tWidth: %ld\n\tHeight: %ld",
//              (long)obj.window.frame.origin.x,
//              (long)obj.window.frame.origin.y,
//              (long)obj.window.frame.size.width,
//              (long)obj.window.frame.size.height);
        
        if (self.enabledVisualizer) {
            [self addBorderAnimationOnView:obj.view];
            [self takeScreenshotFromTouch:obj];
            
        }
        
        FingerPrintViewController* rootController = (FingerPrintViewController*)obj.window.rootViewController;
        //[self listSubviewsOfView:rootController.view withSpacing:@""];
        
        for (UIView* obj in rootController.view.subviews) {
                    }
        
        if (obj.view == rootController.button) {
            NSLog(@"hooray, you found the button");
        } else if (obj.view == rootController.testButton) {
            NSLog(@"hooray, you found the test button");
        }
        
        //NSLog(obj.debugDescription);
        
        [self listSubviewsOfView:obj.view withSpacing:@""];
        
    }
    
    //NSLog(@"touchesBegn: %@", touches.allObjects);
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesMoved: %@", touches.allObjects);
    [super touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesEnded: %@", touches.allObjects);
    [super touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   // NSLog(@"touchesCancelled: %@", touches.allObjects);
    [super touchesCancelled:touches withEvent:event];
}

- (void) takeScreenshotFromTouch:(UITouch*)touch {
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
    NSData* data = UIImagePNGRepresentation(image);
    //Save the image at the designated path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:filePath contents:data attributes:nil]) {
        NSLog(@"File Saved");
    } else {
        NSLog(@"Oops, file didn't save :(");
    }

}

- (void) listSubviewsOfView:(UIView *)view withSpacing:(NSString*)spacing {
    
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

- (void) addBorderAnimationOnView:(UIView*)view {
    view.layer.borderWidth = 1;
    CABasicAnimation* borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = (id)[UIColor orangeColor].CGColor;
    borderAnimation.toValue = (id)[UIColor clearColor].CGColor;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    borderAnimation.duration =  .75;//[CATransaction animationDuration];
    borderAnimation.timingFunction = [CATransaction animationTimingFunction];
    [view.layer addAnimation:borderAnimation forKey:@"animationTest"];
}

@end
