//
//  AMBThemeManagerUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/6/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBThemeManager.h"

@interface AMBThemeManagerUnitTests : XCTestCase

@property (nonatomic, strong)AMBThemeManager * themeManager;

@end

@implementation AMBThemeManagerUnitTests

- (void)setUp {
    [super setUp];
    self.themeManager = [AMBThemeManager sharedInstance];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testColorForKey {
    // GIVEN
    UIColor *mockNavBarColor = [self colorFromHexString:@"#FFFFFF"];
    UIColor *mockSendButtonColor = [self colorFromHexString:@"#4199D1"];
    UIColor *expectedNavBarColor;
    UIColor *expectedSendButtonColor;
    
    // WHEN
    expectedNavBarColor = [self.themeManager colorForKey:NavBarColor];
    expectedSendButtonColor = [self.themeManager colorForKey:ContactSendButtonBackgroundColor];
    
    // THEN
    XCTAssertEqualObjects(mockNavBarColor, expectedNavBarColor, @"Expected %@ and got %@", mockNavBarColor, expectedNavBarColor);
    XCTAssertEqualObjects(mockSendButtonColor, expectedSendButtonColor, @"Expected %@ and got %@", mockSendButtonColor, expectedSendButtonColor);
}

- (void)testMessageForKey {
    // GIVEN
    NSString *mockNavBarTitleMessage = @"Refer your friends";
    NSString *mockWelcomeMessage = @"Spread the word";
    NSString *expectedNavMessage;
    NSString *expectedWelcomeMessage;
    
    // WHEN
    expectedNavMessage = [self.themeManager messageForKey:NavBarTextMessage];
    expectedWelcomeMessage = [self.themeManager messageForKey:RAFWelcomeTextMessage];
    
    // THEN
    XCTAssertTrue([mockNavBarTitleMessage isEqualToString:expectedNavMessage], @"%@ is not equal to %@", mockNavBarTitleMessage, expectedNavMessage);
    XCTAssertTrue([mockWelcomeMessage isEqualToString:expectedWelcomeMessage], @"%@ is not equal to %@", mockWelcomeMessage, expectedWelcomeMessage);
}

// Helper function that returns a color from a hex code
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
