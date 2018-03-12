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
#import "AmbassadorLoginViewController.h"

@interface MyTabBarController() <AmbassadorLoginDelegate>

@property (nonatomic) BOOL hasPerformedRunWithKeys;

@end


@implementation MyTabBarController

NSString * loginSegue = @"ambassador_login_segue";

- (void)viewDidLoad {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [self checkForLogin];
}

- (void)checkForLogin {
    if ([[DefaultsHandler getSDKToken] isEqualToString:@""] || [[DefaultsHandler getUniversalID] isEqualToString:@""]) {
        [self performSegueWithIdentifier:loginSegue sender:self];
    } else {
        [AmbassadorSDK runWithUniversalToken:[DefaultsHandler getSDKToken] universalID:[DefaultsHandler getUniversalID]];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // Grabs the index of viewController based on tag set in storyboards
    NSInteger itemIndex = item.tag;
    
    NSDictionary *infoDict = @{@"email": @"jay+iostrack@example.com"};
    [AmbassadorSDK identifyWithUserID:@"" traits:infoDict completion:^(BOOL success){
        AMBWelcomeScreenParameters *params = [[AMBWelcomeScreenParameters alloc] init];
        params.referralMessage = @"{{ name }} has referred you to Ambassador!";
        params.detailMessage = @"You understand the value of referrals. Maybe you've even explored referral marketing software.";
        params.actionButtonTitle = @"CREATE AN ACCOUNT";
        params.linkArray = @[@"Testimonials", @"Request Demo"];
        params.accentColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
        
        [AmbassadorSDK presentWelcomeScreen:params ifAvailable:^(AMBWelcomeScreenViewController *welcomeScreenVC) {
            welcomeScreenVC.delegate = self;
            [self presentViewController:welcomeScreenVC animated:YES completion:nil];
        }];
    }];
    
    // Grabs the viewController that will be presented and refreshes it
    UIViewController *controller = self.viewControllers[itemIndex];
    [controller viewWillAppear:YES];
}


#pragma mark - Ambassador Login Delegate

- (void)userSuccessfullyLoggedIn {
    [self checkForLogin];
}

@end
