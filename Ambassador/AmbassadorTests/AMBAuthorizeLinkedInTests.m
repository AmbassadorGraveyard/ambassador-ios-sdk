//
//  AMBAuthorizeLinkedInTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/26/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBAuthorizeLinkedIn.h"
#import "AMBUtilities.h"
#import "AMBNetworkManager.h"

@interface AMBAuthorizeLinkedIn (Test) <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)viewDidLoad;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)saveValuesFromQueryParams:(NSArray*)queryParameters;

@end


@interface AMBAuthorizeLinkedInTests : XCTestCase

@property (nonatomic, strong) AMBAuthorizeLinkedIn * ambAuthorizeLinkedin;

@end

@implementation AMBAuthorizeLinkedInTests

- (void)setUp {
    [super setUp];
    if (!self.ambAuthorizeLinkedin) {
        self.ambAuthorizeLinkedin = [[AMBAuthorizeLinkedIn alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testViewDidLoad {
    // GIVEN
    NSString *titleString = @"Authorize LinkedIn";
    
    // WHEN
    [self.ambAuthorizeLinkedin viewDidLoad];
    
    // THEN
    XCTAssertEqualObjects(titleString, self.ambAuthorizeLinkedin.navigationItem.title);
}

- (void)testWillAnimateRotation {
    // GIVEN
    id mockUtilities = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[mockUtilities expect] rotateLoadingView:self.ambAuthorizeLinkedin.view orientation:UIInterfaceOrientationLandscapeRight];
    
    // WHEN
    [self.ambAuthorizeLinkedin willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:2];
    
    // THEN
    OCMVerify([mockUtilities rotateLoadingView:self.ambAuthorizeLinkedin.view orientation:UIInterfaceOrientationLandscapeRight]);
}


#pragma mark - WebView Delegate Tests

- (void)testWebViewLoadDelegate {
    // GIVEN
    NSURLRequest *mockRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com?test=test1"]];
    
    // WHEN
    BOOL shouldLoad = [self.ambAuthorizeLinkedin webView:self.ambAuthorizeLinkedin.webView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeBackForward];
    
    // THEN
    XCTAssertTrue([self.ambAuthorizeLinkedin conformsToProtocol:@protocol(UIWebViewDelegate)]);
    XCTAssertTrue(shouldLoad);
}

- (void)testWebViewFinishLoadDelegate {
    // GIVEN
    id mockUtilities = [OCMockObject partialMockForObject:[AMBUtilities sharedInstance]];
    [[mockUtilities expect] hideLoadingView];
    
    // WHEN
    [self.ambAuthorizeLinkedin webViewDidFinishLoad:self.ambAuthorizeLinkedin.webView];
    
    // THEN
    [mockUtilities verify];
}


#pragma mark - Helper Function Tests

- (void)testSaveValueFromQueryParamsWithError {
    // GIVEN
    NSArray *mockErrorParamArray = @[@"error=therewasanerror"];
    
    id mockNavigationController = [OCMockObject mockForClass:[UINavigationController class]];
    [[mockNavigationController expect] popViewControllerAnimated:YES];
    
    id mockVC = [OCMockObject partialMockForObject:self.ambAuthorizeLinkedin];
    [[[mockVC expect] andReturn:mockNavigationController] navigationController];
    
    // WHEN
    [self.ambAuthorizeLinkedin saveValuesFromQueryParams:mockErrorParamArray];
    
    // THEN
    [mockNavigationController verify];
}

- (void)testSaveValueFromQueryParamsWithCode {
    // GIVEN
     NSArray *mockParamArray = @[@"code=thisisatestcode"];
    
    id mockNetworkManager = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[mockNetworkManager expect] getLinkedInRequestTokenWithKey:@"thisisatestcode" success:[OCMArg any] failure:[OCMArg any]];
   
    // WHEN
    [self.ambAuthorizeLinkedin saveValuesFromQueryParams:mockParamArray];
    
    // THEN
    [mockNetworkManager verify];
}

@end
