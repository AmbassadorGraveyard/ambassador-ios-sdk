//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//


#import "AMBIdentify.h"
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "AMBErrors.h"
#import "AMBNetworkObject.h"
#import "AMBPusherChannelObject.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBUtilities.h"
#import <WebKit/WebKit.h>


@interface AMBIdentify () <SFSafariViewControllerDelegate, UIWebViewDelegate, WKNavigationDelegate>

@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic, strong) NSTimer * identifyTimer;

@end

@implementation AMBIdentify

- (void)identifyWithUniversalID:(NSString*)universalID completion:(void(^)(NSMutableDictionary *returnDict, NSError *error))completion {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
        [self performIdentifyForiOS9];
        self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(performIdentifyForiOS9) userInfo:nil repeats:YES];
    } else {
        if (![AMBValues getDeviceFingerPrint] || ![AMBValues getMbsyCookieCode]) { // Checks to see if we already have the values
            [self performDeepLink];
        }
    }
}

- (void)performIdentifyForiOS9 {
    self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AmbassadorSDK sharedInstance].universalID]]];
    DLog(@"Performing Identify with SAFARI VC for iOS 9");
    [self.safariVC.view setHidden:YES];
    self.safariVC.delegate = self;
    
    UIViewController *rootVC = [UIApplication sharedApplication].windows[0].rootViewController;
    
    if (![self.safariVC.view isDescendantOfView:rootVC.view]) {
        [rootVC.view addSubview:self.safariVC.view];
        [rootVC addChildViewController:self.safariVC];
    }
}

- (void)performDeepLink {
    // Opens identify URL in Safari and then deeplinks back to app on redirect
    DLog(@"Performing DeepLink with Safari on iOS 8");
    NSString *identifyURLString = [AMBValues identifyUrlWithUniversalID:[AmbassadorSDK sharedInstance].universalID];
    NSURL *identifyURL = [NSURL URLWithString:identifyURLString];
    [[UIApplication sharedApplication] openURL:identifyURL]; // Tells the App Delegate to lauch the url in Safari which will eventually redirect us back
}

- (void)performIdentifyiOS8 {

}


#pragma mark - SFSafari ViewController Delegate

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // When the safari VC has finished loading our page, we silently remove it from the rootVC.
    [self.safariVC.view removeFromSuperview];
    [self.safariVC removeFromParentViewController];
    if (didLoadSuccessfully) { [self.identifyTimer invalidate]; } // If the load was successful, we kill the retry timer
}

@end