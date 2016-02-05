//
//  AMBErrors.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMBOptions.h"

@interface AMBErrors : NSObject

// Error Logs
+ (void)errorLogCannotSendConversion:(NSInteger)statusCode errorData:(NSData*)data;
+ (void)errorLogNoMatchingCampaignIdError:(NSString*)campaignId;

// NSErrors
+ (NSError*)restrictedConversionError;

// AlertView Errors
+ (void)errorAlertNoMatchingCampaignIdsForVC:(UIViewController*)viewController;
+ (void)errorLinkedInShareForVC:(UIViewController*)viewController withMessage:(NSString*)message;
+ (void)errorLinkedInReauthForVC:(UIViewController*)viewController;
+ (void)errorNetworkTimeoutForVC:(UIViewController*)viewController;
+ (void)errorSharingMessageForVC:(UIViewController*)viewController withErrorMessage:(NSString*)message;
+ (void)errorSendingInvalidPhoneNumbersForVC:(UIViewController*)viewController;
+ (void)errorSendingInvalidEmailsForVC:(UIViewController*)viewController;
+ (void)errorSelectingInvalidValueForValue:(NSString*)valueString type:(AMBSocialServiceType)serviceType;
+ (void)errorLoadingContactsForVC:(UIViewController*)viewController;

@end


