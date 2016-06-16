//
//  AMBSMSHandlerTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBSMSHandler.h"
#import "AMBContactSelector.h"
#import "AMBNetworkManager.h"
#import "AMBBulkShareHelper.h"
#import "AMBValues.h"
#import "AMBErrors.h"
#import <MessageUI/MessageUI.h>

@interface AMBSMSHandler (Test) <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) AMBContactSelector * parentController;
@property (nonatomic, strong) NSArray * contactArray;
@property (nonatomic, strong) NSString * messageString;

- (BOOL)alreadyHaveNames;
- (void)checkCountForSending;
- (void)sendBulkViaTwilio;
- (void)sendViaDirectSMS;

@end


@interface AMBSMSHandlerTests : XCTestCase

@property (nonatomic, strong) AMBSMSHandler * handler;
@property (nonatomic) id mockHandler;

@end

@implementation AMBSMSHandlerTests

- (void)setUp {
    [super setUp];
    if (!self.handler) {
        self.handler = [[AMBSMSHandler alloc] init];
    }
    
    self.mockHandler = [OCMockObject partialMockForObject:self.handler];
}

- (void)tearDown {
    [self.mockHandler stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle

- (void)testInitWithController {
    // GIVEN
    AMBContactSelector *selector = [[AMBContactSelector alloc] init];
    
    [[[self.mockHandler expect] andReturn:self.mockHandler] alloc];
    self.mockHandler = [[[self.mockHandler expect] andDo:nil] initWithController:selector];
    [[[self.mockHandler expect] andDo:nil] setParentController:selector];
    
    // WHEN
    self.handler = [[AMBSMSHandler alloc] initWithController:selector];
    
    // THEN
    [self.mockHandler verify];
}


#pragma mark - Send Functions

- (void)testSendSMSWithMessage {
    // GIVEN
    NSString *message = @"Test Message";
    [[[self.mockHandler expect] andReturnValue:OCMOCK_VALUE(YES)] alreadyHaveNames];
    [[[self.mockHandler expect] andDo:nil] checkCountForSending];
    
    // WHEN
    [self.handler sendSMSWithMessage:message];
    
    // THEN
    [self.mockHandler verify];
    XCTAssertEqualObjects(message, self.handler.messageString);
}

- (void)testSendBulkViaTwilio {
    // GIVEN
    NSString *message = @"Message";
    self.handler.messageString = message;
    
    id mockMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)(NSDictionary *messageDict) = nil;
        [invocation getArgument:&success atIndex:3];
    }] bulkShareSmsWithMessage:message phoneNumbers:[OCMArg any] success:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBSMSHandlerDelegate)];
    [[[mockDelegate expect] andDo:nil] AMBSMSHandlerMessageSharedSuccessfullyWithContacts:[OCMArg any]];
    
    self.handler.delegate = mockDelegate;
    
    // WHEN
    [self.handler sendBulkViaTwilio];
    
    // THEN
    [mockMgr verify];
    [mockDelegate verify];
    
    [mockMgr stopMocking];
    [mockDelegate stopMocking];
}

- (void)testSendViaDirectSMSSim {
    // GIVEN
    id mockMF = [OCMockObject mockForClass:[MFMessageComposeViewController class]];
    [[[mockMF expect] andReturnValue:OCMOCK_VALUE(NO)] canSendText];
    
    [[[self.mockHandler expect] andDo:nil] sendBulkViaTwilio];
    
    // WHEN
    [self.handler sendViaDirectSMS];
    
    // THEN
    [mockMF verify];
    [self.mockHandler verify];
    
    [mockMF stopMocking];
}

- (void)testSendViaDirectSMSDevice {
    // GIVEN
    id mockMF = [OCMockObject mockForClass:[MFMessageComposeViewController class]];
    [[[mockMF expect] andReturnValue:OCMOCK_VALUE(YES)] canSendText];

    id mockParentController = [OCMockObject mockForClass:[AMBContactSelector class]];
    [[[mockParentController expect] andDo:nil] presentViewController:[OCMArg any] animated:YES completion:nil];
    self.handler.parentController = mockParentController;
    
    // WHEN
    [self.handler sendViaDirectSMS];
    
    // THEN
    [mockMF verify];
    [mockParentController verify];
    
    [mockMF stopMocking];
    [mockParentController stopMocking];
}


#pragma mark - Setters

- (void)testSetContacts {
    // GIVEN
    NSArray *fakeArray = @[@"555-555-5555", @"123-456-7890"];
    
    id mockBulk = [OCMockObject mockForClass:[AMBBulkShareHelper class]];
    [[[mockBulk expect] andDo:nil] validatedPhoneNumbers:fakeArray];
    
    // WHEN
    [self.handler setContacts:fakeArray];
    
    // THEN
    [mockBulk verify];
    [mockBulk stopMocking];
}


#pragma mark - MFMessageComposeViewController Delegate

- (void)testDidFinishWithResult {
    // GIVEN
    id mockParent = [OCMockObject mockForClass:[AMBContactSelector class]];
    self.handler.parentController = mockParent;
    
    [[[mockParent expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    [[[mockParent expect] andDo:nil] registerForKeyboardNotifications];
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(AMBSMSHandlerDelegate)];
    [[[mockDelegate expect] andDo:nil] AMBSMSHandlerMessageSharedSuccessfullyWithContacts:[OCMArg any]];
    self.handler.delegate = mockDelegate;
    
    // WHEN
    [self.handler messageComposeViewController:[[MFMessageComposeViewController alloc] init] didFinishWithResult: MessageComposeResultSent];
    
    // THEN
    [mockParent verify];
    [mockDelegate verify];
    
    [mockParent stopMocking];
    [mockDelegate stopMocking];
}


#pragma mark - Helper Functions

- (void)testAlreadyHaveNames {
    // GIVEN
    [AMBValues setUserFirstNameWithString:@"First"];
    [AMBValues setUserLastNameWithString:@"Last"];
    
    // WHEN
    BOOL haveNames = [self.handler alreadyHaveNames];
    
    [AMBValues setUserLastNameWithString:@""];
    [AMBValues setUserFirstNameWithString:@""];
    BOOL haveNames2 = [self.handler alreadyHaveNames];
    
    // THEN
    XCTAssertTrue(haveNames);
    XCTAssertFalse(haveNames2);
}

- (void)testCheckCountForSending {
    // WHEN
    id mockError = [OCMockObject mockForClass:[AMBErrors class]];
    [[[mockError expect] andDo:nil] errorSendingInvalidPhoneNumbersForVC:[OCMArg any]];
    [self.handler checkCountForSending];
    
    self.handler.contactArray = @[@"555-555-5555"];
    [[[self.mockHandler expect] andDo:nil] sendViaDirectSMS];
    [self.handler checkCountForSending];
    
    self.handler.contactArray = @[@"555-555-5555", @"123-456-7890"];
    [[[self.mockHandler expect] andDo:nil] sendBulkViaTwilio];
    [self.handler checkCountForSending];
    
    
    // THEN
    [mockError verify];
    [self.mockHandler verify];
    
    [mockError stopMocking];
}

@end
