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

@interface AmbassadorSDK () <AMBInputAlertDelegate>

+ (AmbassadorSDK*)sharedInstance;
- (void)subscribeToPusherWithCompletion:(void(^)())completion;

@property (nonatomic, strong) AMBPusherManager *pusherManager;
@property (nonatomic, strong) AMBUserNetworkObject *user;
@property (nonatomic, strong) NSString *universalToken;
@property (nonatomic, strong) NSString *universalID;

// Used to call present RAF is email prompt presented
@property (nonatomic, weak) NSString * tempCampID;
@property (nonatomic, weak) NSString * tempPlistName;
@property (nonatomic, weak) UIViewController * tempPresentController;

@end
