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
    // UI Testing setup
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"isUITesting"]) {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    }

    [AmbassadorSDK runWithUniversalToken:@"9de5757f801ca60916599fa3f3c92131b0e63c6a" universalID:@"abfd1c89-4379-44e2-8361-ee7b87332e32"]; // DEV CREDENTIALS
//    [AmbassadorSDK runWithUniversalToken:@"84444f4022a8cd4fce299114bc2e323e57e32188" universalID:@"830883cd-b2a7-449c-8a3c-d1850aa8bc6b"]; // PROD CREDENTIALS

    [AmbassadorSDK identifyWithEmail:@"jake@getambassador.com"];
    
    AMBConversionParameters *fakeInstallConversion = [[AMBConversionParameters alloc] init];
    fakeInstallConversion.mbsy_campaign = @260;
    fakeInstallConversion.mbsy_revenue = @200;
    fakeInstallConversion.mbsy_email = @"greg@getambassador.com";
    fakeInstallConversion.mbsy_custom1 = @"installConversion";
    
    [AmbassadorSDK registerConversion:fakeInstallConversion restrictToInstall:YES completion:^(NSError *error) {
        if (error) {
            NSLog(@"Conversion not registered - %@", error);
        } else {
            NSLog(@"INSTALL CONVERSION REGISTERED SUCCESSFULLY!");
        }
    }];

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
