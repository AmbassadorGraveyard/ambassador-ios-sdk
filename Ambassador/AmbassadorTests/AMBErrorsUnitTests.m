//
//  AMBErrorsUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBErrors.h"
#import "AMBUtilities.h"
#import "AMBSendCompletionModal.h"
#import "UIAlertController+CancelAlertController.h"

@interface AMBErrorsUnitTests : XCTestCase

@property (nonatomic) id mockVC;
@property (nonatomic) id mockUtilites;
@property (nonatomic, strong) AMBUtilities * utilities;
@property (nonatomic, strong) UIViewController * viewController;

@end

@implementation AMBErrorsUnitTests

- (void)setUp {
    [super setUp];
    if (!self.utilities) { self.utilities = [AMBUtilities sharedInstance]; }
    if (!self.viewController) { self.viewController = [[UIViewController alloc] init]; }
    self.mockVC = [OCMockObject partialMockForObject:self.viewController];
    self.mockUtilites = [OCMockObject partialMockForObject:self.utilities];
}

- (void)tearDown {
    [self.mockVC stopMocking];
    [self.mockUtilites stopMocking];
    [super tearDown];
}


#pragma mark - Error Logs

- (void)testErrorLogCannotSendConversion {
    // GIVEN
    NSInteger mockStatusCode = 400;
    
    // WHEN
    [AMBErrors errorLogCannotSendConversion:mockStatusCode errorData:nil];
}

- (void)testErrorLogNoMatchingCampaign {
    // GIVEN
    NSString *mockCampId = @"1000";
    
    // WHEN
    [AMBErrors errorLogNoMatchingCampaignIdError:mockCampId];
}


#pragma mark - NSErrors Tests

- (void)testRestrictedConversionError {
    // GIVEN
    NSString *mockErrorDomain = @"AmbassadorErrorDomain";
    
    // WHEN
    NSError *error = [AMBErrors restrictedConversionError];
    
    // THEN
    XCTAssertEqualObjects(mockErrorDomain, error.domain);
}


#pragma mark - Custom Alert Errors

- (void)testAlertErrorNoMatchingIds {
    // GIVEN
    [self mockCustomAlert];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:[OCMArg isKindOfClass:[NSString class]] withUniqueID:nil forViewController:[OCMArg any] shouldDismissVCImmediately:YES];
    
    // WHEN
    [AMBErrors errorAlertNoMatchingCampaignIdsForVC:self.mockVC];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertAppNotInstalled {
    // GIVEN
    [self mockCustomAlert];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"Make sure you have Facebook installed and are logged in to continue." withUniqueID:@"appNotInstalled" forViewController:self.mockVC shouldDismissVCImmediately:NO];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"Make sure you have Twitter installed and are logged in to continue." withUniqueID:@"appNotInstalled" forViewController:self.mockVC shouldDismissVCImmediately:NO];
    
    // WHEN
    [AMBErrors appNotInstalled:self.mockVC app:@"Facebook"];
    [AMBErrors appNotInstalled:self.mockVC app:@"Twitter"];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertErrorLinkedInShare {
    // GIVEN
    NSString *errorMessage = @"Error message";
    id mockOperation = [OCMockObject partialMockForObject:[NSOperationQueue mainQueue]];
    [[[mockOperation expect] andDo:nil] addOperationWithBlock:[OCMArg any]];
    
    // WHEN
    [AMBErrors errorLinkedInShareForVC:self.mockVC withMessage:errorMessage];
    
    // THEN
    [mockOperation verify];
}

- (void)testAlertErrorLinkdInReauth {
    // GIVEN
    id mockOperation = [OCMockObject partialMockForObject:[NSOperationQueue mainQueue]];
    [[[mockOperation expect] andDo:nil] addOperationWithBlock:[OCMArg any]];
    
    // WHEN
    [AMBErrors errorLinkedInReauthForVC:self.mockVC];
    
    // THEN
    [mockOperation verify];
}

- (void)testAlertErrorNetworkTimeout {
    // GIVEN
    [self mockCustomAlert];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"The network request has timed out. Please check your connection and try again." withUniqueID:@"networkTimeOut" forViewController:self.mockVC shouldDismissVCImmediately:YES];
    
    // WHEN
    [AMBErrors errorNetworkTimeoutForVC:self.mockVC];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertErrorSharingMessage {
    // GIVEN
    NSString *errorMessage = @"Error message";
    [self mockCustomAlert];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:self.mockVC shouldDismissVCImmediately:NO];
    
    // WHEN
    [AMBErrors errorSharingMessageForVC:self.mockVC withErrorMessage:errorMessage];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertErrorSendingInvalidPhoneNumber {
    // GIVEN
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"You may have selected an invalid phone number. Please check and try again." withUniqueID:nil forViewController:self.mockVC shouldDismissVCImmediately:NO];
    
    // WHEN
    [AMBErrors errorSendingInvalidPhoneNumbersForVC:self.mockVC];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertErrorSendingInvalidEmail {
    // GIVEN
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"You may have selected an invalid email address. Please check and try again." withUniqueID:nil forViewController:self.mockVC shouldDismissVCImmediately:NO];
    
    // WHEN
    [AMBErrors errorSendingInvalidEmailsForVC:self.mockVC];
    
    // THEN
    [self.mockUtilites verify];
}

- (void)testAlertErrorSelectingInvalidValue {
    // GIVEN
    NSString *invalidValue = @"123543465";
    AMBSocialServiceType serviceType = AMBSocialServiceTypeFacebook;
    
    // WHEN
    [AMBErrors errorSelectingInvalidValueForValue:invalidValue type:serviceType];
}

- (void)testAlertErrorLoadingContacts {
    // GIVEN
    [self mockCustomAlert];
    [[[self.mockUtilites expect] andDo:nil] presentAlertWithSuccess:NO message:@"Sharing requires access to your contact book. You can enable this in your settings." withUniqueID:@"contactError" forViewController:self.mockVC shouldDismissVCImmediately:NO];
    
    // WHEN
    [AMBErrors errorLoadingContactsForVC:self.mockVC];
    
    // THEN
    [self.mockUtilites verify];
}


#pragma mark - Helper Functions

- (void)mockCustomAlert {
    id mockSB = [OCMockObject mockForClass:[UIStoryboard class]];
    id mockVC = [OCMockObject mockForClass:[AMBSendCompletionModal class]];
    [[[mockSB expect] andDo:nil] storyboardWithName:@"Main" bundle:[OCMArg any]];
    [[[mockSB expect] andReturn:mockVC] instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    [[[self.mockVC expect] andDo:nil] presentViewController:[OCMArg any] animated:YES completion:nil];
}

@end
