//
//  AMBErrors.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBErrors.h"

@implementation AMBErrors


#pragma mark - Error Logs

+ (void)errorLogCannotSendConversion:(NSInteger)statusCode errorData:(NSData*)data {
    DLog(@"[Ambassador] Error Sending Conversion - Status Code=%li Failure Reason=%@", (long)statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
}

+ (void)errorLogNoMatchingCampaignIdError:(NSString*)campaignId {
    NSLog(@"[Ambassador] Error loading RAF - There were no Campaign IDs found matching '%@'.  Please make sure that the correct Campaign ID is being passed when presenting a RAF widget", campaignId);
}


#pragma mark - NSErrors

+ (NSError*)restrictedConversionError {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Conversion was not registered", nil),
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The conversion is restricted to install", nil),
                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Change the Conversion's 'restrictToInstall' boolean to NO/false", nil) };
    
    return [NSError errorWithDomain:@"AmbassadorErrorDomain" code:0 userInfo:userInfo];
}


#pragma mark - AlertView Errors

+ (void)errorAlertNoMatchingCampaignIdsForVC:(UIViewController*)viewController {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"No matching campaigns were found!" withUniqueID:nil forViewController:viewController shouldDismissVCImmediately:YES];
}

+ (void)errorLinkedInShareForVC:(UIViewController*)viewController withMessage:(NSString*)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:message withUniqueID:@"linkedShareFail" forViewController:viewController shouldDismissVCImmediately:NO];
    }];
}

+ (void)errorLinkedInReauthForVC:(UIViewController*)viewController {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You've been logged out of LinkedIn. Please login to share." withUniqueID:@"linkedInAuth" forViewController:viewController shouldDismissVCImmediately:NO];
    }];
}

+ (void)errorNetworkTimeoutForVC:(UIViewController*)viewController {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"The network request has timed out. Please check your connection and try again." withUniqueID:@"networkTimeOut" forViewController:viewController shouldDismissVCImmediately:YES];
}

+ (void)errorSharingMessageForVC:(UIViewController*)viewController withErrorMessage:(NSString*)message {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:viewController shouldDismissVCImmediately:NO];
    NSLog(@"[Ambassador] Error Sharing Message - %@", message);
}

+ (void)errorSendingInvalidPhoneNumbersForVC:(UIViewController*)viewController {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid phone number. Please check and try again." withUniqueID:nil forViewController:viewController shouldDismissVCImmediately:NO];
}

+ (void)errorSendingInvalidEmailsForVC:(UIViewController*)viewController {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid email address. Please check and try again." withUniqueID:nil forViewController:viewController shouldDismissVCImmediately:NO];
}

+ (void)errorSelectingInvalidValueForValue:(NSString*)valueString type:(AMBSocialServiceType)serviceType {
    NSString *errorString;
    
    switch (serviceType) {
        case AMBSocialServiceTypeEmail:
            errorString = [NSString stringWithFormat:@"The email address %@ is invalid.  Please change it to a valid email address. \n(Example: user.name@example.com)", valueString];
            break;
        case AMBSocialServiceTypeSMS:
            errorString = [NSString stringWithFormat:@"The phone number %@ is invalid.  Please change it to a valid phone number. \n(Example: 1-(555)555-5555, (555)555-5555, 555-5555)", valueString];
        default:
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to select!" message:errorString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
}

+ (void)errorLoadingContactsForVC:(UIViewController*)viewController {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Sharing requires access to your contact book. You can enable this in your settings." withUniqueID:@"contactError" forViewController:viewController shouldDismissVCImmediately:NO];
}

@end
