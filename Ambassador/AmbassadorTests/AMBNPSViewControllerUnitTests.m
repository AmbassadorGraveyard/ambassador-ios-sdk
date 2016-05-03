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
#import "AMBSurveySlider.h"

// Category to access private vars/functions
@interface AMBNPSViewController (Test) <AMBSurveySliderDelegate>

@property (nonatomic, strong) NSDictionary * payloadDict;
@property (nonatomic, weak) IBOutlet UIButton * btnClose;
@property (nonatomic, weak) IBOutlet UIButton * btnSubmit;
@property (nonatomic, weak) IBOutlet UILabel * lblWelcomeMessage;
@property (nonatomic, weak) IBOutlet UILabel * lblDetailMessage;
@property (nonatomic, weak) IBOutlet AMBSurveySlider * slider;
@property (nonatomic, strong) NSString * selectedValue;

- (void)setupUI;
- (IBAction)closeSurvey:(id)sender;
- (IBAction)submitTapped:(id)sender;
- (UIColor *)npsMainBackgroundColor;
- (UIColor *)npsContentColor;
- (UIColor *)npsButtonColor;

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

- (void)testSubmitTapped {
    // GIVEN
    [[[self.mockNPSVC expect] andDo:nil] dismissViewControllerAnimated:YES completion:nil];
    
    // WHEN
    [self.mockNPSVC submitTapped:nil];
    
    // THEN
    [self.mockNPSVC verify];
}


#pragma mark - AMBSurveySlider Delegate

- (void)testSurveySliderValueSelected {
    // GIVEN
    NSString *testValue = @"TESTVALUE";
    self.npsViewController.slider.delegate = self.npsViewController;
    
    // WHEN
    [self.npsViewController AMBSurveySlider:self.npsViewController.slider valueSelected:testValue];
    
    // THEN
    XCTAssertEqualObjects(testValue, self.npsViewController.selectedValue);
}


#pragma mark - UI Function Tests

- (void)testNPSMainBackgroundColor {
    // GIVEN
    UIColor *yellow = [UIColor yellowColor];
    UIColor *green = [UIColor greenColor];
    
    // WHEN
    self.npsViewController.view.backgroundColor = green;
    UIColor *color1 = [self.npsViewController npsMainBackgroundColor];
    
    self.npsViewController.mainBackgroundColor = yellow;
    UIColor *color2 = [self.npsViewController npsMainBackgroundColor];
    
    // THEN
    XCTAssertEqualObjects(green, color1);
    XCTAssertEqualObjects(yellow, color2);
}

- (void)testNPSContentColor {
    // GIVEN
    UIColor *white = [UIColor whiteColor];
    UIColor *black = [UIColor blackColor];
    
    // WHEN
    UIColor *color1 = [self.npsViewController npsContentColor];
    
    self.npsViewController.contentColor = black;
    UIColor *color2 = [self.npsViewController npsContentColor];
    
    // THEN
    XCTAssertEqualObjects(white, color1);
    XCTAssertEqualObjects(black, color2);
}

- (void)testNPSButtonColor {
    // GIVEN
    UIColor *red = [UIColor redColor];
    UIColor *blue = [UIColor blueColor];
    
    id mockSubmitButton = [OCMockObject mockForClass:[UIButton class]];
    [[[mockSubmitButton expect] andReturn:red] backgroundColor];
    [[[mockSubmitButton expect] andDo:nil] setBackgroundColor:red];
    self.npsViewController.btnSubmit = mockSubmitButton;
    
    // WHEN
    self.npsViewController.btnSubmit.backgroundColor = red;
    UIColor *color1 = [self.npsViewController npsButtonColor];
    
    self.npsViewController.buttonColor = blue;
    UIColor *color2 = [self.npsViewController npsButtonColor];
    
    // THEN
    XCTAssertEqualObjects(red, color1);
    XCTAssertEqualObjects(blue, color2);
}

@end
