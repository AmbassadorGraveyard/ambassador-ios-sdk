//
//  UIApplication+Analytics.m
//  ObjC
//
//  Created by Diplomat on 5/20/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "UIApplication+Analytics.h"
#import "JRSwizzle.h"

@implementation UIApplication (Analytics)

+ (void)load {
    [UIApplication jr_swizzleMethod:@selector(sendAction:to:forEvent:) withMethod:@selector(analyze_sendAction:to:forEvent:) error:nil];
    [UIApplication jr_swizzleMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(analyze_sendAction:to:from:forEvent:) error:nil];
    [UIApplication jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(analyze_sendEvent:) error:nil];
}

- (BOOL)analyze_sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event {
    NSLog(@"/n/n/n%@", NSStringFromSelector(action));
    return [self analyze_sendAction:action to:target forEvent:event];
}

- (BOOL)analyze_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent*)event {
    NSLog(@"[%@ %@, %@ %ld]", NSStringFromSelector(action), [target description], [target description], event.type);
    return [self analyze_sendAction:action to:target from:sender forEvent:event];
}

- (void)analyze_sendEvent:(UIEvent *)event {
    NSLog(@"Event Logged %ld, %ld", event.type, event.subtype);
    [self analyze_sendEvent:event];
}



@end
