//
//  RAFNavigationController.m
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "RAFNavigationController.h"
#import "Utilities.h"

@implementation RAFNavigationController

- (void)viewDidLoad
{
    DLog();
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (BOOL)shouldAutorotate
{
    DLog();
    return NO;
}

@end
