//
//  MyController.m
//  ObjC
//
//  Created by Diplomat on 5/20/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "MyController.h"

@implementation MyController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Event was caught: %ld", (long)event.type);
    NSMutableArray* touchArr = [NSMutableArray arrayWithArray:[[event allTouches] allObjects]];
    
    UITouch* touch = touchArr[0];
    [self addBorderAnimationOnView:touch.view];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesMoved: %@", touches.allObjects);
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesEnded: %@", touches.allObjects);
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // NSLog(@"touchesCancelled: %@", touches.allObjects);
    [super touchesCancelled:touches withEvent:event];
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

@end
