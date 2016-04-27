//
//  AmbassadorHelper.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/27/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmbassadorHelper : NSObject

+ (void)setDelay:(CGFloat)delayTime finished:(void(^)())finished;

@end
