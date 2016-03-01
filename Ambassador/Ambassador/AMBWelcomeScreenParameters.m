//
//  AMBWelcomScreenParamets.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenParameters.h"
#import <UIKit/UIKit.h>

@implementation AMBWelcomeScreenParameters


#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    self.referralMessage = @"You have been referred to this company";
    self.detailMessage = @"Welcome to our app!";
    self.linkArray = @[];
    self.accentColor = [UIColor redColor];
    
    return self;
}

@end
