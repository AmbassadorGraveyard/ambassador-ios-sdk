//
//  AMBIdenityUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <SafariServices/SafariServices.h>
#import "AMBIdentify.h"
#import "AMBValues.h"

@interface AMBIdentify (Tests) <SFSafariViewControllerDelegate>

@property (nonatomic, strong) NSTimer * identifyTimer;
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic) NSInteger tryCount;

- (void)deviceInfoReceived;
- (void)performIdentifyForiOS9;

@end


@interface AMBIdenityUnitTests : XCTestCase

@property (nonatomic, strong) AMBIdentify * identify;

@end


@implementation AMBIdenityUnitTests

- (void)setUp {
    [super setUp];
    if (!self.identify) {
        self.identify = [[AMBIdentify alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testInit {
    // GIVEN
    NSInteger expectedTry = 0;
    
    // WHEN
    AMBIdentify *identify = [[AMBIdentify alloc] init];
    
    // THEN
    XCTAssertEqual(expectedTry, identify.tryCount);
}

- (void)testGetIdentify {
    // GIVEN
    id mockIdentify = [OCMockObject partialMockForObject:self.identify];
    
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
        [[[mockIdentify expect] andDo:nil] performIdentifyForiOS9];
    }
    
    // WHEN
    [self.identify getIdentity];
    
    // THEN
    [mockIdentify verify];
    XCTAssertNotNil(self.identify.identifyTimer);
}

- (void)testPerformIdentifyForiOS9 {
    // WHEN
    [self.identify performIdentifyForiOS9];
    
    // THEN
    XCTAssertNotNil(self.identify.safariVC);
    XCTAssertTrue([self.identify.safariVC.view isHidden]);
}

- (void)testDeviceInfoReceived {
    // GIVEN
    id mockTimer = [OCMockObject mockForClass:[NSTimer class]];
    [[[mockTimer expect] andDo:nil] invalidate];
    self.identify.identifyTimer = mockTimer;
    
    // WHEN
    [self.identify deviceInfoReceived];
    
    // THEN
    [mockTimer verify];
    [mockTimer stopMocking];
}


#pragma mark - SafariViewController Delegate

- (void)testSFVCDidCompleteInitialLoad {
    // GIVEN
    id mockSFVC = [OCMockObject mockForClass:[SFSafariViewController class]];
    [[[mockSFVC expect] andDo:nil] removeFromParentViewController];
    
    id mockSFView = [OCMockObject mockForClass:[UIView class]];
    [[[mockSFView expect] andDo:nil] removeFromSuperview];
    [[[mockSFVC expect] andReturn:mockSFView] view];
    
    // WHEN
    [self.identify safariViewController:mockSFVC didCompleteInitialLoad:YES];
    
    // THEN
    [mockSFVC verify];
    [mockSFView verify];
    
    [mockSFVC stopMocking];
    [mockSFView stopMocking];
}

@end
