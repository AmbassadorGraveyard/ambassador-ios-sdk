//
//  MyTabBarController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "MyTabBarController.h"
#import "DefaultsHandler.h"
#import <Ambassador/Ambassador.h>

@interface MyTabBarController()

@property (nonatomic) BOOL hasPerformedRunWithKeys;

@end


@implementation MyTabBarController

NSString * loginSegue = @"ambassador_login_segue";

- (void)viewDidLoad {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)viewDidAppear:(BOOL)animated {
    if (![self hasPerformedRunWithKeys]) {
        [self checkForLogin];
    }
}

- (void)checkForLogin {
    if ([[DefaultsHandler getSDKToken] isEqualToString:@""] || [[DefaultsHandler getUniversalID] isEqualToString:@""]) {
        [self performSegueWithIdentifier:loginSegue sender:self];
    } else {
        self.hasPerformedRunWithKeys = YES;
        [AmbassadorSDK runWithUniversalToken:[DefaultsHandler getSDKToken] universalID:[DefaultsHandler getUniversalID]];
    }
}

@end