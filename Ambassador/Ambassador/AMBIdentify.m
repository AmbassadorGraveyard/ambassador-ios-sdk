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
@property (nonatomic) NSInteger tryCount;

@end

@implementation AMBIdentify

NSInteger const maxTryCount = 5;


#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    self.tryCount = 0;
    return self;
}


#pragma mark - Identify Functions

- (void)getIdentity {
    if (![AMBValues isUITestRun]) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
            [self performIdentifyForiOS9];
            self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(performIdentifyForiOS9) userInfo:nil repeats:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoReceived) name:@"deviceInfoReceived" object:nil];
        }
    }
}

- (void)performIdentifyForiOS9 {
    // Checks if try count is at its max
    if (self.tryCount >= maxTryCount) {
        [self.identifyTimer invalidate];
        return;
    }
    
    self.tryCount++;
    self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AMBValues getUniversalID]]]];
    DLog(@"Performing Identify with SAFARI VC for iOS 9 - Attempt %li", (long)self.tryCount);
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