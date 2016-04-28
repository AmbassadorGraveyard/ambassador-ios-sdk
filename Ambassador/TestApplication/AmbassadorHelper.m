//
//  AmbassadorHelper.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/27/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AmbassadorHelper.h"

@implementation AmbassadorHelper

// Creates a delay in the thread to separate events
+ (void)setDelay:(CGFloat)delayTime finished:(void(^)())finished {
    dispatch_time_t finishedTime = dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC);
    dispatch_after(finishedTime, dispatch_get_main_queue(), ^(void){
        finished();
    });
}

@end
