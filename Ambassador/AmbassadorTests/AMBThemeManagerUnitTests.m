//
//  AMBThemeManagerUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/6/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBThemeManager.h"
#import "UIColor+AMBColorValues.h"

@interface AMBThemeManager(Test)

- (void)createDicFromPlist:(NSString*)plistName;
- (NSString*)colorEnumStringValue:(AmbassadorColors)enumValue;
- (NSString*)messageEnumStringValue:(AmbassadorMessages)enumValue;
- (NSString*)fontEnumStringValue:(AmbassadorFonts)enumValue;
- (NSString*)imageEnumStringValue:(AmbassadorImages)enumValue;
- (NSString*)sizeEnumStringValue:(AmbassadorSizes)enumValue;

@end


@interface AMBThemeManagerUnitTests : XCTestCase

@property (nonatomic, strong) AMBThemeManager * themeManager;
@property (nonatomic) id mockThemeManager;

@end

@implementation AMBThemeManagerUnitTests

- (void)setUp {
    [super setUp];
    if (!self.themeManager) {
        self.themeManager = [AMBThemeManager sharedInstance];
        [self.themeManager createDicFromPlist:@"GenericTheme"];
    }
    
    self.mockThemeManager = [OCMockObject partialMockForObject:self.themeManager];
}

- (void)tearDown {
    [self.mockThemeManager stopMocking];
    [super tearDown];
}


#pragma mark - Colors Tests

- (void)testColorForKey {
    // GIVEN
    UIColor *mockNavBarColor = [UIColor colorFromHexString:@"#FFFFFF"];
    UIColor *mockSendButtonColor = [UIColor colorFromHexString:@"#4199D1"];
    UIColor *expectedNavBarColor;
    UIColor *expectedSendButtonColor;
    
    // WHEN
    expectedNavBarColor = [self.themeManager colorForKey:NavBarColor];
    expectedSendButtonColor = [self.themeManager colorForKey:ContactSendButtonBackgroundColor];
    
    // THEN
    XCTAssertEqualObjects(mockNavBarColor, expectedNavBarColor, @"Expected %@ and got %@", mockNavBarColor, expectedNavBarColor);
    XCTAssertEqualObjects(mockSendButtonColor, expectedSendButtonColor, @"Expected %@ and got %@", mockSendButtonColor, expectedSendButtonColor);
}

- (void)testColorEnumString {
    // GIVEN
    BOOL passing = YES;
    NSArray *expectedStringArray = @[@"NavBarColor", @"NavBarTextColor", @"RAFBackgroundColor", @"RAFWelcomeTextColor", @"RAFDescriptionTextColor",
                                     @"ContactSendButtonBackgroundColor", @"ContactSendButtonTextColor", @"ContactSearchBackgroundColor",
                                     @"ContactSearchDoneButtonTextColor", @"ContactTableCheckMarkColor", @"ContactAvatarBackgroundColor",
                                     @"ContactAvatarColor", @"ShareFieldBackgroundColor", @"ShareFieldTextColor", @"AlertButtonBackgroundColor",
                                     @"AlertButtonTextColor"];
    
    NSArray *enumArray = @[[NSNumber numberWithInt:NavBarColor], [NSNumber numberWithInt:NavBarTextColor], [NSNumber numberWithInt:RAFBackgroundColor],
                           [NSNumber numberWithInt:RAFWelcomeTextColor], [NSNumber numberWithInt:RAFDescriptionTextColor],
                           [NSNumber numberWithInt:ContactSendButtonBackgroundColor], [NSNumber numberWithInt:ContactSendButtonTextColor],
                           [NSNumber numberWithInt:ContactSearchBackgroundColor], [NSNumber numberWithInt:ContactSearchDoneButtonTextColor],
                           [NSNumber numberWithInt:ContactTableCheckMarkColor], [NSNumber numberWithInt:ContactAvatarBackgroundColor],
                           [NSNumber numberWithInt:ContactAvatarColor], [NSNumber numberWithInt:ShareFieldBackgroundColor],
                           [NSNumber numberWithInt:ShareFieldTextColor], [NSNumber numberWithInt:AlertButtonBackgroundColor],
                           [NSNumber numberWithInt:AlertButtonTextColor]];
                                     
    // WHEN
    for (int i = 0; i < [enumArray count]; i++) {
        if (![expectedStringArray[i] isEqualToString:[self.themeManager colorEnumStringValue:[enumArray[i] intValue]]]) {
            passing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(passing);
}


#pragma mark - Messages Tests

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

- (void)testMessageEnumString {
    // GIVEN
    BOOL passing = YES;
    NSArray *expectedStringArray = @[@"NavBarTextMessage", @"RAFWelcomeTextMessage", @"RAFDescriptionTextMessage", @"DefaultShareMessage"];
    NSArray *enumArray = @[[NSNumber numberWithInt:NavBarTextMessage], [NSNumber numberWithInt:RAFWelcomeTextMessage],
                           [NSNumber numberWithInt:RAFDescriptionTextMessage], [NSNumber numberWithInt:DefaultShareMessage]];
    
    // WHEN
    for (int i = 0; i < [enumArray count]; i++) {
        if (![expectedStringArray[i] isEqualToString:[self.themeManager messageEnumStringValue:[enumArray[i] intValue]]]) {
            passing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(passing);
}


#pragma mark - Fonts Tests

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

- (void)testFontEnumString {
    // GIVEN
    BOOL passing = YES;
    NSArray *expectedStringArray = @[@"NavBarTextFont", @"RAFWelcomeTextFont", @"RAFDescriptionTextFont", @"ContactTableNameTextFont",
                                     @"ContactTableInfoTextFont", @"ContactSendButtonTextFont", @"ShareFieldTextFont"];
    
    NSArray *enumArray = @[[NSNumber numberWithInt:NavBarTextFont], [NSNumber numberWithInt:RAFWelcomeTextFont], [NSNumber numberWithInt:RAFDescriptionTextFont],
                           [NSNumber numberWithInt:ContactTableNameTextFont], [NSNumber numberWithInt:ContactTableInfoTextFont],
                           [NSNumber numberWithInt:ContactSendButtonTextFont], [NSNumber numberWithInt:ShareFieldTextFont]];
    
    // WHEN
    for (int i = 0; i < [expectedStringArray count] ; i++) {
        if (![expectedStringArray[i] isEqualToString:[self.themeManager fontEnumStringValue:[enumArray[i] intValue]]]) {
            passing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(passing);
}


#pragma mark - Images Tests

- (void)testImageForKey {
    // GIVEN
    UIImage *mockAppleImage = [UIImage imageNamed:@"unitTestImage"];
    NSMutableDictionary *mockReturnValue = [[NSMutableDictionary alloc] initWithObjectsAndKeys:mockAppleImage, @"image", nil];
    [mockReturnValue setValue:@"1" forKey:@"imageSlotNumber"];
    NSMutableDictionary *expectedReturnValue;
    
    // WHEN
    expectedReturnValue = [self.themeManager imageForKey:RAFLogo];
    
    // THEN
    XCTAssertNotNil(expectedReturnValue);
    XCTAssertEqualObjects(mockReturnValue[@"imageSlotNumber"], expectedReturnValue[@"imageSlotNumber"], @"%@ is not equal to %@", mockReturnValue[@"imageSlotNumber"], expectedReturnValue[@"imageSlotNumber"]);
}

- (void)testImageEnumString {
    // GIVEN
    BOOL passing = YES;
    NSArray *expectedStringArray = @[@"RAFLogo"];
    NSArray *enumArray = @[[NSNumber numberWithInt:RAFLogo]];
    
    // WHEN
    for (int i = 0; i < [enumArray count]; i++) {
        if (![expectedStringArray[i] isEqualToString:[self.themeManager imageEnumStringValue:[enumArray[i] intValue]]]) {
            passing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(passing);
}


#pragma mark - Size Tests

- (void)testSizeForKey {
    // GIVEN
    NSNumber *expectedNumber = @35;
    
    // WHEN
    NSNumber *realNumber = [self.themeManager sizeForKey:ShareFieldHeight];
    NSNumber *failNumber = [self.themeManager sizeForKey:100];
    
    // THEN
    XCTAssertEqualObjects(expectedNumber, realNumber);
    XCTAssertNil(failNumber);
}

- (void)testSizeEnumString {
    // GIVEN
    BOOL passing = YES;
    NSArray *expectedStringArray = @[@"ShareFieldHeight", @"ShareFieldCornerRadius"];
    NSArray *enumArray = @[[NSNumber numberWithInt:ShareFieldHeight], [NSNumber numberWithInt:ShareFieldCornerRadius]];
    
    // WHEN
    for (int i = 0; i < [enumArray count]; i++) {
        if (![expectedStringArray[i] isEqualToString:[self.themeManager sizeEnumStringValue:[enumArray[i] intValue]]]) {
            passing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(passing);
}

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


#pragma mark - UIColor Category Tests

- (void)testTwitterBlue {
    // GIVEN
    UIColor *expectedColor = [UIColor colorFromHexString:@"#469AE9"];
    
    // WHEN
    UIColor *twitterBlue = [UIColor twitterBlue];
    
    // THEN
    XCTAssertEqualObjects(expectedColor, twitterBlue);
}

- (void)testFBBlue {
    // GIVEN
    UIColor *expectedColor = [UIColor colorFromHexString:@"#2E4486"];
    
    // WHEN
    UIColor *fbBlue = [UIColor faceBookBlue];
    
    // THEN
    XCTAssertEqualObjects(expectedColor, fbBlue);
}

- (void)testLinkedinBlue {
    // GIVEN
    UIColor *expectedColor = [UIColor colorFromHexString:@"#0E62A6"];
    
    // WHEN
    UIColor *linkedinBlue = [UIColor linkedInBlue];
    
    // THEN
    XCTAssertEqualObjects(expectedColor, linkedinBlue);
}

- (void)testErrorRed {
    // GIVEN
    UIColor *expectedColor = [UIColor colorFromHexString:@"#AE0015"];
    
    // WHEN
    UIColor *errorRed = [UIColor errorRed];
    
    // THEN
    XCTAssertEqualObjects(expectedColor, errorRed);
}

- (void)testCellSelectionGray {
    // GIVEN
    UIColor *expectedColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    
    // WHEN
    UIColor *cellSelectionGray = [UIColor cellSelectionGray];
    
    // THEN
    XCTAssertEqualObjects(expectedColor, cellSelectionGray);
}

@end
