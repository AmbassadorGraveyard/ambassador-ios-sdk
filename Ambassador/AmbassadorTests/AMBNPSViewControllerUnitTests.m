//
//  AMBNPSViewControllerUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/8/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBNPSViewController.h"

// Category to access private vars/functions
@interface AMBNPSViewController (Test)

@property (nonatomic, strong) NSDictionary * payloadDict;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;

- (void)setupUI;
- (IBAction)closeSurvey:(id)sender;

@end


@interface AMBNPSViewControllerUnitTests : XCTestCase

@property (nonatomic, strong) AMBNPSViewController * npsViewController;
@property (nonatomic) id mockNPSVC;

@end


@implementation AMBNPSViewControllerUnitTests

- (void)setUp {
    [super setUp];
    if (!self.npsViewController) {
        self.npsViewController = [[AMBNPSViewController alloc] init];
    }
    
    self.mockNPSVC = [OCMockObject partialMockForObject:self.npsViewController];
}

- (void)tearDown {
    [self.mockNPSVC stopMocking];
    [super tearDown];
}


#pragma mark - LifeCycle Tests

- (void)testInitWithPayload {
    // GIVEN
    NSDictionary *fakeDict = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    id mockStoryboard = [OCMockObject mockForClass:[UIStoryboard class]];
    [[[mockStoryboard expect] andReturn:mockStoryboard] storyboardWithName:@"Main" bundle:[OCMArg any]];
    [[[mockStoryboard expect] andReturn:self.npsViewController] instantiateViewControllerWithIdentifier:@"NPS_MODAL_VIEW"];
    
    // WHEN
    self.npsViewController = [[AMBNPSViewController alloc] initWithPayload:fakeDict];
    NSDictionary *expectedDict = self.npsViewController.payloadDict;
    
    // THEN
    XCTAssertEqualObjects(fakeDict[@"key1"], expectedDict[@"key1"]);
    XCTAssertEqualObjects(fakeDict[@"key2"], expectedDict[@"key2"]);
    [mockStoryboard verify];
    
    [mockStoryboard stopMocking];
}

- (void)testViewDidLoad {
    // GIVEN
    [[[self.mockNPSVC expect] andDo:nil] setupUI];
    
    // WHEN
    [self.npsViewController viewDidLoad];
    
    // THEN
    [self.mockNPSVC verify];
}


#pragma mark - Action Tests

- (void)testCloseSurvey {
    // GIVEN
    [[[self.mockNPSVC expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.mockNPSVC closeSurvey:nil];
    
    // THEN
    [self.mockNPSVC verify];
}


#pragma mark - UI Function Tests

- (void)testSetupUI {
    // GIVEN
    id mockImage = [OCMockObject mockForClass:[UIImage class]];
    [[[mockImage expect] andDo:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    id mockImageView = [OCMockObject mockForClass:[UIImageView class]];
    [[[mockImageView expect] andReturn:mockImage] image];
    
    id mockButton = [OCMockObject mockForClass:[UIButton class]];
    [[[mockButton expect] andDo:nil] setImage:[OCMArg any] forState:UIControlStateNormal];
    [[[mockButton expect] andDo:nil] setTintColor:[UIColor whiteColor]];
    [[[mockButton expect] andReturn:mockImageView] imageView];
    
    self.npsViewController.btnClose = mockButton;
    
    // WHEN
    [self.npsViewController setupUI];
    
    // THEN
    [mockButton verify];
    [mockButton stopMocking];
}

@end
