//
//  AMBSMSHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/10/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBSMSHandler.h"
#import <MessageUI/MessageUI.h>
#import "AMBBulkShareHelper.h"
#import "AMBNetworkManager.h"
#import "AMBErrors.h"

@interface AMBSMSHandler() <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIViewController * parentController;
@property (nonatomic, strong) NSArray * contactArray;
@property (nonatomic, strong) NSString * messageString;

@end


@implementation AMBSMSHandler


#pragma mark - LifeCycle

- (instancetype)initWithController:(UIViewController*)controller {
    self = [super init];
    self.parentController = controller;
    
    return self;
}


#pragma mark - Send Functions

- (void)sendSMSWithMessage:(NSString*)message {
    self.messageString = message;
    
    if ([self alreadyHaveNames]) {
        [self checkCountForSending];
    }
}

- (void)sendBulkViaTwilio {
    [[AMBNetworkManager sharedInstance] bulkShareSmsWithMessage:self.messageString phoneNumbers:self.contactArray success:^(NSDictionary *response) {
        [self.delegate AMBSMSHandlerMessageSharedSuccessfullyWithContacts:self.contactArray];
    } failure:^(NSString *error) {
        [self.delegate AMBSMSHandlerMessageShareFailureWithError:error];
    }];
}

- (void)sendViaDirectSMS {
    if (![MFMessageComposeViewController canSendText]) {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"This device does not support SMS" withUniqueID:@"unsupportedSMS" forViewController:self.parentController shouldDismissVCImmediately:NO];
        return;
    }
    
    // Sets up an SMS Message ViewController
    MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
    smsController.messageComposeDelegate = self;
    [smsController setRecipients:self.contactArray];
    [smsController setBody:self.messageString];
    
    [self.parentController presentViewController:smsController animated:YES completion:nil];
}


#pragma mark - Setters

- (void)setContacts:(NSArray*)contactArray {
    // Instantly validates numbers
    NSArray *validatedArray = (NSArray*)[AMBBulkShareHelper validatedPhoneNumbers:contactArray];
    self.contactArray = [NSArray arrayWithArray:validatedArray];
}


#pragma mark - MFMessageCompose ViewController Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        [self.delegate AMBSMSHandlerMessageSharedSuccessfullyWithContacts:self.contactArray];
    } else if (result == MessageComposeResultFailed) {
        [self.delegate AMBSMSHandlerMessageShareFailureWithError:@"MFMessageComposeViewController failed to send SMS message"];
    }
    
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Helper Functions

- (BOOL)alreadyHaveNames {
    NSString *firstName = [AMBValues getUserFirstName];
    NSString *lastName = [AMBValues getUserLastName];
    
    if (![AMBUtilities stringIsEmpty:firstName] || ![AMBUtilities stringIsEmpty:lastName]) {
        return YES;
    } else {
        [self.delegate AMBSMSHandlerRequestName];
        return NO;
    }
}

- (void)checkCountForSending {
    switch (self.contactArray.count) {
        case 0:
            [AMBErrors errorSendingInvalidPhoneNumbersForVC:self.parentController];
            break;
        case 1:
            [self sendViaDirectSMS];
            break;
        default:
            [self sendBulkViaTwilio];
            break;
    }
}

@end
