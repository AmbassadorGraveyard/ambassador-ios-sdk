//
//  AmbassadorSDK_Internal.h
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Ambassador/Ambassador.h>
#import "AMBPusherChannelObject.h"
#import "AMBNetworkObject.h"
#import "AMBPusherManager.h"
#import "AMBPusher.h"
#import "AMBWelcomeScreenViewController_Internal.h"
#import "AMBInputAlert.h"
#import "AMBNPSViewController.h"
#import "AMBIdentify.h"
#import "AMBConversion.h"
#import "AMBConversionParameter_Internal.h"

@interface AmbassadorSDK () <AMBInputAlertDelegate>

+ (AmbassadorSDK*)sharedInstance;
- (void)subscribeToPusherWithSuccess:(void(^)())success;

@property (nonatomic) BOOL identifyInProgress;
@property (nonatomic, strong) AMBPusherManager *pusherManager;
@property (nonatomic, strong) AMBIdentify *identify;
@property (nonatomic, strong) AMBUserNetworkObject *user;
@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) NSString *universalID;
@property (nonatomic, strong) AMBConversion *conversion;

// Used to call present RAF is email prompt presented
@property (nonatomic, weak) NSString * tempCampID;
@property (nonatomic, weak) NSString * tempPlistName;
@property (nonatomic, weak) UIViewController * tempPresentController;

// Temp vars used to call presentNPS with arguments passed if through alertcontroller
@property (nonatomic, weak) NSDictionary * notificationData;
@property (nonatomic, weak) UIColor * npsBackgroundColor;
@property (nonatomic, weak) UIColor * npsContentColor;
@property (nonatomic, weak) UIColor * npsButtonColor;

@end
