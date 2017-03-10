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
@property (nonatomic, strong) NSTimer * identifyFinishedTimer;
@property (nonatomic) NSInteger tryCountFinish;
@property (nonatomic) NSInteger tryCount;
@property (nonatomic, copy) void (^identifyCompletion)(BOOL);
@property (nonatomic) BOOL identifyCompletionCalled; // this is to make sure that the callback isn't called 2x
@property (nonatomic) NSDate * startDate;
@property (nonatomic) NSInteger minimumTime;

@end

@implementation AMBIdentify

// Constants
NSInteger const maxTryCount = 10;


#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    self.tryCount = 0;
    self.tryCountFinish = 0;
    self.identifyCompletionCalled = NO;
    self.minimumTime = [self getMinimumTime];
    self.startDate = nil;
    return self;
}

- (NSInteger)getMinimumTime{

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *plistPath = [mainBundle pathForResource:@"GenericTheme" ofType:@"plist"];

    NSBundle *ambassadorBundle = [AMBValues AMBframeworkBundle];
    if (!plistPath){
        plistPath = [ambassadorBundle pathForResource:@"GenericTheme" ofType:@"plist"];
    }

    NSDictionary *valuesDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSNumber *loaderTime = nil;
    if ((int)[valuesDic valueForKey:@"LandingPageMinimumSeconds"]){
        loaderTime = [valuesDic valueForKey:@"LandingPageMinimumSeconds"];
    }
    else{
        loaderTime = [NSNumber numberWithInt:2];
    }
    NSInteger minimumTime = [loaderTime integerValue];
    if (minimumTime > 30){
        minimumTime = 30;
    }else if (minimumTime < 2){
        minimumTime = 2;
    }
    return minimumTime;
}


#pragma mark - Identify Functions

- (void)getIdentity:(void (^)(BOOL))completion{
    // set completion handler
    if (completion){ self.identifyCompletion = completion; self.identifyCompletionCalled = NO;}
    // If a the run is a UI test, we don't identify
    if (![AMBValues isUITestRun]) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
            [self performIdentifyForiOS10];
            
            // Checks to make sure the timer is not already running before instantiating a new one
            if (!self.identifyTimer.isValid) {
                self.tryCount = 0;
                self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(performIdentifyForiOS10) userInfo:nil repeats:YES];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoReceived) name:@"deviceInfoReceived" object:nil];
        }
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
        [[AmbassadorSDK sharedInstance].pusherManager closeSocket];
        BOOL success = YES;
        if (self.safariVC && ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0)) {
            [self.safariVC dismissViewControllerAnimated:YES completion:^{
                if (self.identifyCompletion && !self.identifyCompletionCalled) { self.identifyCompletion(success); self.identifyCompletionCalled = YES;}
            }];
        }else{
            if (self.identifyCompletion && !self.identifyCompletionCalled) { self.identifyCompletion(success); self.identifyCompletionCalled = YES;}
        }
        return;
    }
    self.tryCount++;

    if ((self.identifyProcessComplete == YES) || !([[AMBValues getDeviceFingerPrint] isEqual:@{}])) {
        [self deviceInfoReceived];
        return;
    }

    // Checks to see if the Safari ViewController has already been initialized
    if (!self.safariVC) {
        self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AMBValues getUniversalID]]]];
    }
    self.safariVC.delegate = self;

    DLog(@"[Identify] Performing Identify with SAFARI VC for iOS 10 - Attempt %li.", (long)self.tryCount);
    
    // Gets the top viewController and adds the safari VC to it if not already added
    UIViewController *topVC = [AMBUtilities getTopViewController];
    if (![self.safariVC.view isDescendantOfView:topVC.view]) {
        self.safariVC.modalPresentationStyle = UIModalPresentationPopover;
        self.safariVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.safariVC.popoverPresentationController.sourceView = topVC.view;
        [topVC presentViewController:self.safariVC animated:YES completion:nil];
        if (!self.startDate){
            self.startDate = [NSDate date];
        }
    }
}

- (void)deviceInfoReceived {
    [self.identifyTimer invalidate];
    NSInteger secondsSinceStart = (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate];
    if (secondsSinceStart < self.minimumTime){
        NSInteger difference = self.minimumTime - secondsSinceStart;
        if (!self.identifyFinishedTimer.isValid) {
            self.identifyFinishedTimer = [NSTimer scheduledTimerWithTimeInterval:difference target:self selector:@selector(finishIdentify) userInfo:nil repeats:YES];
        }
    }else{
        if (self.safariVC && ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0)) {
            [self.safariVC dismissViewControllerAnimated:YES completion:^{
                [self identifyComplete];
            }];
        }
        else{
            [self identifyComplete];
        }
    }
}

- (void)finishIdentify {
    [self.identifyFinishedTimer invalidate];
    if (self.safariVC && ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0)) {
        [self.safariVC dismissViewControllerAnimated:YES completion:^{
            [self identifyComplete];
        }];
    }
    else{
        [self identifyComplete];
    }
}

- (void)deviceInfoReceivedNoWait {
    [self.identifyTimer invalidate];
    [self.identifyFinishedTimer invalidate];
    [self identifyComplete];
}

// Called when either the identify response is returned or the max try count is reached
- (void)identifyComplete {
    self.identifyProcessComplete = YES;
    [[AmbassadorSDK sharedInstance].pusherManager closeSocket];
    BOOL success = YES;
    if (self.identifyCompletion && !self.identifyCompletionCalled) { self.identifyCompletion(success); self.identifyCompletionCalled = YES;}
}


#pragma mark - SFSafariViewController Delegate

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    if ((self.identifyProcessComplete == YES) || !([[AMBValues getDeviceFingerPrint] isEqual:@{}])) {
        [self.identifyFinishedTimer invalidate];
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
        [self deviceInfoReceivedNoWait];
    }
}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Removes the safari VC after inital load
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 9) {
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
}

@end
