//
//  CustomActivityViewOne.m
//  ObjC
//
//  Created by Diplomat on 5/19/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "CustomActivityViewOne.h"

@implementation CustomActivityViewOne

- (NSString*)activityType { return @"ObjC.Review.App"; }

- (NSString*)activityTitle { return @"Review Activity"; }

- (UIImage*)activityImage { return [UIImage imageNamed:@"grumpybeard-vice-city_360.png"]; }

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s", __FUNCTION__);
}

- (UIViewController*)activityViewController {
     NSLog(@"%s", __FUNCTION__);
    return nil;
}

- (void)performActivity {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.getambassador.com"]];
    [self activityDidFinish:YES];
}

@end
