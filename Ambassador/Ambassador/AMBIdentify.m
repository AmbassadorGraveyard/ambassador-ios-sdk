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

@interface AMBIdentify () <SFSafariViewControllerDelegate>

@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic, strong) NSTimer * identifyTimer;

@end

@implementation AMBIdentify

- (void)getIdentity {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
        [self performIdentifyForiOS9];
        self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(performIdentifyForiOS9) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoReceived) name:@"deviceInfoReceived" object:nil];
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

- (void)deviceInfoReceived {
    [self.safariVC.view removeFromSuperview];
    [self.safariVC removeFromParentViewController];
    [self.identifyTimer invalidate];
}

@end