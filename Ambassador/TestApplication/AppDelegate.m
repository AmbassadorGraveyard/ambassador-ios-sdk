//
//  AppDelegate.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AppDelegate.h"
#import <Ambassador/Ambassador.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
    [self setUpAppearance];
    
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"isUITesting"]) {
        [UIView setAnimationsEnabled:NO];
        [AmbassadorSDK runWithUniversalToken:@"7a654edde7929be3708db90fdad0b1c04ad79ad1" universalID:@"32a7540b-0000-4dcc-8ea3-4ea145e40f0d"]; // DEV CREDENTIALS
    }

    [self setUpAppearance];
    
    [AmbassadorSDK runWithUniversalToken:@"***REMOVED***" universalID:@"***REMOVED***"]; // DEV CREDENTIALS
//    [AmbassadorSDK runWithUniversalToken:@"***REMOVED***" universalID:@"***REMOVED***"]; // PROD CREDENTIALS

    // Registers app for notifications
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil];
    [application registerForRemoteNotifications];
    [application registerUserNotificationSettings:settings];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [AmbassadorSDK registerDeviceToken:token];
    NSLog(@"Device Token = %@", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [AmbassadorSDK handleAmbassadorRemoteNotification:userInfo];
    NSLog(@"Info received from notification - %@", userInfo);
}


#pragma mark - Helper Functions

- (void)setUpAppearance {
    [[UITabBar appearance] setBarTintColor:[AppDelegate colorFromHexString:@"#25313f"]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
