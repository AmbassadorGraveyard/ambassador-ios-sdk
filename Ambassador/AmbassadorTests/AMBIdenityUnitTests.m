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

@interface AMBIdentify (Tests)

@property (nonatomic, strong) NSTimer * identifyTimer;
@property (nonatomic, strong) SFSafariViewController * safariVC;

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
    self.identify.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://google.com"]];
    id mockSafariVC = [OCMockObject partialMockForObject:self.identify.safariVC];
    id mockView = [OCMockObject partialMockForObject:self.identify.safariVC.view];

    [[[mockSafariVC expect] andDo:nil] removeFromParentViewController];
    [[[mockView expect] andDo:nil] removeFromSuperview];
    
    // WHEN
    [self.identify deviceInfoReceived];
    
    // THEN
    [mockSafariVC verify];
    [mockView verify];
}

@end
