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

- (void)testViewDidLoad {
    // GIVEN
    NSString *titleString = @"LinkedIn";
    NSString *fakeDefaultMessage = @"Share stuff!";
    self.linkedInShareVC.defaultMessage = fakeDefaultMessage;
    
    // WHEN
    [self.linkedInShareVC viewDidLoad];
    
    // THEN
    XCTAssertEqualObjects(titleString, self.linkedInShareVC.title);
    XCTAssertEqualObjects(fakeDefaultMessage, self.linkedInShareVC.textView.text);
}

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
    id delegate = [OCMockObject mockForProtocol:@protocol(AMBShareServiceDelegate)];
    self.linkedInShareVC.delegate = delegate;
    [[[delegate expect] andDo:nil] userDidPostFromService:[OCMArg isKindOfClass:[NSString class]]];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)() = nil;
        [invocation getArgument:&success atIndex:3];
        success(@"ACCESS_TOKEN");
    }] shareToLinkedInWithMessage:[OCMArg isKindOfClass:[NSString class]] success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.linkedInShareVC didSelectPost];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
    
    [delegate verify];
    [delegate stopMocking];
}

- (void)testFailureBlock {
    // GIVEN
    id delegate = [OCMockObject mockForProtocol:@protocol(AMBShareServiceDelegate)];
    self.linkedInShareVC.delegate = delegate;
    [[[delegate expect] andDo:nil] networkError:[OCMArg isKindOfClass:[NSString class]] message:[OCMArg isKindOfClass:[NSString class]]];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^failure)() = nil;
        [invocation getArgument:&failure atIndex:4];
        failure(@"ERROR");
    }] shareToLinkedInWithMessage:[OCMArg isKindOfClass:[NSString class]] success:[OCMArg any] failure:[OCMArg any]];
    
    // WHEN
    [self.linkedInShareVC didSelectPost];
    
    // THEN
    [mockNetworkMgr verify];
    [mockNetworkMgr stopMocking];
    
    [delegate verify];
    [delegate stopMocking];
}

@end
