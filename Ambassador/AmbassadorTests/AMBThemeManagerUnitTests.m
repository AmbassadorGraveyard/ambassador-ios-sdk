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

- (void)testFontForKey {
    // GIVEN
    UIFont *mockNavBarFont = [UIFont fontWithName:@"Helvetica" size:20];
    UIFont *mockWelcomeFont = [UIFont fontWithName:@"HelveticaNeue" size:22];
    UIFont *expectedNavBarFont;
    UIFont *expectedWelcomeFont;
    
    // WHEN
    expectedNavBarFont = [self.themeManager fontForKey:NavBarTextFont];
    expectedWelcomeFont = [self.themeManager fontForKey:RAFWelcomeTextFont];
    
    // THEN
    XCTAssertEqualObjects(mockNavBarFont, expectedNavBarFont, @"%@ is not equal to %@", mockNavBarFont, expectedNavBarFont);
    XCTAssertEqualObjects(mockWelcomeFont, expectedWelcomeFont, @"%@ is not equal to %@", mockWelcomeFont, expectedWelcomeFont);
}

//- (void)testImageForKey {
//    // GIVEN
//    UIImage *mockAppleImage = [UIImage imageNamed:@"appleLogo"];
//    NSMutableDictionary *mockReturnValue = [[NSMutableDictionary alloc] initWithObjectsAndKeys:mockAppleImage, @"image", nil];
//    [mockReturnValue setValue:@"0" forKey:@"imageSlotNumber"];
//    NSMutableDictionary *expectedReturnValue;
//    
//    // WHEN
//    expectedReturnValue = [self.themeManager imageForKey:RAFLogo];
//    
//    // THEN
//    XCTAssertNotNil(expectedReturnValue);
//    XCTAssertEqualObjects(mockReturnValue[@"image"], expectedReturnValue[@"image"], @"%@ is not equal to %@", mockReturnValue[@"image"], expectedReturnValue[@"image"]);
//    XCTAssertEqualObjects(mockReturnValue[@"imageSlotNumber"], expectedReturnValue[@"imageSlotNumber"], @"%@ is not equal to %@", mockReturnValue[@"imageSlotNumber"], expectedReturnValue[@"imageSlotNumber"]);
//}

- (void)testCustomSocialGridArray {
    // GIVEN
    NSArray *mockSocialArray = @[@"facebook", @"twitter", @"linkedin", @"sms", @"email"];
    
    // WHEN
    NSArray *expectedSocialArray = [[AMBThemeManager sharedInstance] customSocialGridArray];
    
    // THEN
    XCTAssertEqualObjects(mockSocialArray[0], expectedSocialArray[0]);
    XCTAssertEqualObjects(mockSocialArray[1], expectedSocialArray[1]);
    XCTAssertEqualObjects(mockSocialArray[2], expectedSocialArray[2]);
    XCTAssertEqualObjects(mockSocialArray[3], expectedSocialArray[3]);
    XCTAssertEqualObjects(mockSocialArray[4], expectedSocialArray[4]);
}

- (void)testEnumValueForSocialString {
    // GIVEN
    SocialShareTypes mockFacebook = Facebook;
    SocialShareTypes mockTwitter = Twitter;
    SocialShareTypes mockLinkedin = LinkedIn;
    SocialShareTypes mockSMS = SMS;
    SocialShareTypes mockEmail = Email;
    
    // WHEN
    SocialShareTypes expectedFacebook = [AMBThemeManager enumValueForSocialString:@"facebook"];
    SocialShareTypes expectedTwitter = [AMBThemeManager enumValueForSocialString:@"twitter"];
    SocialShareTypes expectedLinkedin = [AMBThemeManager enumValueForSocialString:@"linkedin"];
    SocialShareTypes expectedSMS = [AMBThemeManager enumValueForSocialString:@"sms"];
    SocialShareTypes expectedEmail = [AMBThemeManager enumValueForSocialString:@"email"];
    
    // THEN
    XCTAssertEqual(mockFacebook, expectedFacebook);
    XCTAssertEqual(mockTwitter, expectedTwitter);
    XCTAssertEqual(mockLinkedin, expectedLinkedin);
    XCTAssertEqual(mockSMS, expectedSMS);
    XCTAssertEqual(mockEmail, expectedEmail);
}

#pragma mark - Helper Functions

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
