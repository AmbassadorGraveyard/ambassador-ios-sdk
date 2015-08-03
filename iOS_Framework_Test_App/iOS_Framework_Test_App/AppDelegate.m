//
//  AppDelegate.m
//  iOS_Framework_Test_App
//
//  Created by Diplomat on 6/23/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AppDelegate.h"
#import <iOS_Framework/iOS_Framework.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ConversionParameters *conversion = [[ConversionParameters alloc] init];
    conversion.mbsy_add_to_group_id = @"134";
    conversion.mbsy_revenue = @1000;
    conversion.mbsy_campaign = @260;
    conversion.mbsy_first_name = @"test";
    conversion.mbsy_last_name = @"one";
    conversion.mbsy_email_new_ambassador = @YES;
    conversion.mbsy_uid = @"uiduiduiduiduiduiduid";
    conversion.mbsy_custom1 = @"custom111";
    conversion.mbsy_custom2 = @"custom222";
    conversion.mbsy_custom3 = @"custom333";
    conversion.mbsy_auto_create = @NO;
    conversion.mbsy_deactivate_new_ambassador = @YES;
    conversion.mbsy_transaction_uid = @"transuidtransuid";
    conversion.mbsy_add_to_group_id = @"123456789";
    conversion.mbsy_event_data1 = @"eventdata1";
    conversion.mbsy_event_data2 = @"eventdata2";
    conversion.mbsy_event_data3 = @"eventdata3";
    conversion.mbsy_is_approved = @NO;
    conversion.mbsy_email = @"anonymous_test_1578@example.com";

    [Ambassador runWithKey:@"UniversalToken ***REMOVED***" convertOnInstall:conversion];
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

@end
