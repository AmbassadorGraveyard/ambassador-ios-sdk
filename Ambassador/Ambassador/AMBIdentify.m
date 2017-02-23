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
#import <MessageUI/MessageUI.h>

@interface AMBIdentify () <SFSafariViewControllerDelegate>

@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic, strong) NSTimer * identifyTimer;
@property (nonatomic) NSInteger tryCount;

@end

@implementation AMBIdentify

// Constants
NSInteger const maxTryCount = 5;
NSInteger const ios10MaxTryCount = 10;


#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    self.tryCount = 0;
    return self;
}


#pragma mark - Identify Functions

- (void)getIdentity {
    // If a the run is a UI test, we don't identify
    if (![AMBValues isUITestRun]) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 10) {
            [self performIdentifyForiOS10];
            
            // Checks to make sure the timer is not already running before instantiating a new one
            if (!self.identifyTimer.isValid) {
                self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(performIdentifyForiOS10) userInfo:nil repeats:YES];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoReceived) name:@"deviceInfoReceived" object:nil];
        } else if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
            [self performIdentifyForiOS9];
            
            // Checks to make sure the timer is not already running before instantiating a new one
            if (!self.identifyTimer.isValid) {
                self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(performIdentifyForiOS9) userInfo:nil repeats:YES];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoReceived) name:@"deviceInfoReceived" object:nil];
        }
    }
}

- (void)performIdentifyForiOS9 {
    // Presenting on an iMessage modal view causes issues
    if ([[AMBUtilities getTopViewController] isKindOfClass:[MFMessageComposeViewController class]]) {
        return;
    }
    
    // Checks if try count is at its max
    if (self.tryCount >= maxTryCount) {
        [self.identifyTimer invalidate];
        [self identifyComplete];
        return;
    }
    
    self.tryCount++;
    
    // Removes the safari VC if page never finished loading
    if (self.safariVC) {
        [self.safariVC.view removeFromSuperview];
        [self.safariVC removeFromParentViewController];
    }
    
    // Checks to see if the Safari ViewController has already been initialized
    if (!self.safariVC) {
        self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AMBValues getUniversalID]]]];
        [self.safariVC.view setHidden:YES];
        self.safariVC.delegate = self;
    }
    
    DLog(@"[Identify] Performing Identify with SAFARI VC for iOS 9 - Attempt %li.", (long)self.tryCount);
    
    // Gets the top viewController and adds the safari VC to it if not already added
    UIViewController *topVC = [AMBUtilities getTopViewController];
    if (![self.safariVC.view isDescendantOfView:topVC.view]) {
        [topVC.view addSubview:self.safariVC.view];
        [topVC addChildViewController:self.safariVC];
    }
}


- (void)performIdentifyForiOS10 {
    // Presenting on an iMessage modal view causes issues
    if ([[AMBUtilities getTopViewController] isKindOfClass:[MFMessageComposeViewController class]]) {
        return;
    }

    // Checks if try count is at its max
    if (self.tryCount >= maxTryCount) {
        [self.identifyTimer invalidate];
        [self identifyComplete];
        if (self.safariVC) {
            [self.safariVC dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    self.tryCount++;

    if ((self.identifyProcessComplete == YES) || !([[AMBValues getDeviceFingerPrint] isEqual:@{}])) {
        [self.identifyTimer invalidate];
        [self identifyComplete];
        if (self.safariVC) {
            [self.safariVC dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }

    // Checks to see if the Safari ViewController has already been initialized
    if (!self.safariVC) {
        self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AMBValues getUniversalID]]]];
    }

    DLog(@"[Identify] Performing Identify with SAFARI VC for iOS 10 - Attempt %li.", (long)self.tryCount);
    
    // Gets the top viewController and adds the safari VC to it if not already added
    UIViewController *topVC = [AMBUtilities getTopViewController];
    if (![self.safariVC.view isDescendantOfView:topVC.view]) {
        [topVC presentViewController:self.safariVC animated:YES completion:nil];
    }
}

- (void)deviceInfoReceived {
    [self.identifyTimer invalidate];
    [self identifyComplete];
    if (self.safariVC && ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 10)) {
        [self.safariVC dismissViewControllerAnimated:YES completion:nil];
    }
}

// Called when either the identify response is returned or the max try count is reached
- (void)identifyComplete {
    self.identifyProcessComplete = YES;
    [[AmbassadorSDK sharedInstance].pusherManager closeSocket];
}


#pragma mark - SFSafariViewController Delegate

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Removes the safari VC after inital load
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 10) {
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
}

@end
