//
//  AMBLinkedInShareTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/26/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBLinkedInShare.h"
#import <Social/Social.h>
#import "AMBNetworkManager.h"

@interface AMBLinkedInShare (Test)

- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)animated;
- (void)didSelectPost;

@end


@interface AMBLinkedInShareTests : XCTestCase 

@property (nonatomic, strong) AMBLinkedInShare * linkedInShareVC;

@end

@implementation AMBLinkedInShareTests

- (void)setUp {
    [super setUp];
    if (!self.linkedInShareVC) {
        self.linkedInShareVC = [[AMBLinkedInShare alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidAppear {
    // GIVEN
    id mockTextView = [OCMockObject mockForClass:[UITextView class]];
    [[mockTextView expect] becomeFirstResponder];
    
    id mockVC = [OCMockObject partialMockForObject:self.linkedInShareVC];
    [[[mockVC expect] andReturn:mockTextView] textView];
    
    // WHEN
    [self.linkedInShareVC viewDidAppear:YES];
    
    // THEN
    [mockTextView verify];
}


#pragma mark - SLComposeView Delegate Tests

- (void)testDidSelectPost {
    // GIVEN
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[mockNetworkMgr expect] shareToLinkedInWithMessage:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
    
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    [[mockPresentingVC expect] dismissViewControllerAnimated:YES completion:nil];
    
    id mockVC = [OCMockObject partialMockForObject:self.linkedInShareVC];
    [[[mockVC expect] andReturn:mockPresentingVC] presentingViewController];
    
    // WHEN
    [self.linkedInShareVC didSelectPost];
    
    // THEN
    [mockNetworkMgr verify];
    [mockPresentingVC verify];
    [mockNetworkMgr stopMocking];
}

- (void)testDidSelectCancel {
    // GIVEN
    id mockPresentingVC = [OCMockObject mockForClass:[UIViewController class]];
    [[mockPresentingVC expect] dismissViewControllerAnimated:YES completion:nil];
    
    id mockVC = [OCMockObject partialMockForObject:self.linkedInShareVC];
    [[[mockVC expect] andReturn:mockPresentingVC] presentingViewController];
    
    // WHEN
    [self.linkedInShareVC didSelectCancel];
    
    // THEN
    [mockPresentingVC verify];
}


#pragma mark - Block Tests

- (void)testSuccessBlock {
    // GIVEN
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)() = nil;
        [invocation getArgument:&success atIndex:3];
        success();
    }] shareToLinkedInWithMessage:[OCMArg isKindOfClass:[NSString class]] success:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    // WHEN
    [self.linkedInShareVC didSelectPost];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
}

- (void)testFailureBlock {
    // GIVEN
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^failure)() = nil;
        [invocation getArgument:&failure atIndex:3];
        failure();
    }] shareToLinkedInWithMessage:[OCMArg isKindOfClass:[NSString class]] success:[OCMArg any] failure:[OCMArg invokeBlock]];
    
    // WHEN
    [self.linkedInShareVC didSelectPost];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
}

@end
