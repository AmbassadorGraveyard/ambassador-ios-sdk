//
//  AMBThemeManager.h
//  Ambassador
//
//  Created by Jake Dunahee on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ambassadorColors {
    // Nav Bar
    NavBarColor,
    NavBarTextColor,
    
    // RAF ViewController
    RAFBackgroundColor,
    RAFWelcomeTextColor,
    RAFDescriptionTextColor,
    ShareFieldBackgroundColor,
    ShareFieldTextColor,
    
    // Contact Selector ViewController
    ContactSendButtonBackgroundColor,
    ContactSearchBackgroundColor,
    ContactSendButtonTextColor,
    ContactSearchDoneButtonTextColor,
    ContactTableCheckMarkColor,
    ContactAvatarBackgroundColor,
    ContactAvatarColor,
    ContactTableBackgroundColor,
    ContactTableNameTextColor,
    ContactTableInfoTextColor,
    
    // Alert Button
    AlertButtonBackgroundColor,
    AlertButtonTextColor
} AmbassadorColors;

typedef enum ambassadorMessages {
    // Nav Bar
    NavBarTextMessage,
    
    // RAF ViewController
    RAFWelcomeTextMessage,
    RAFDescriptionTextMessage,
    DefaultShareMessage
} AmbassadorMessages;

typedef enum ambassadorFonts {
    // Nav bar
    NavBarTextFont,
    
    // RAF ViewController
    RAFWelcomeTextFont,
    RAFDescriptionTextFont,
    ShareFieldTextFont,
    
    // Contact Selector ViewController
    ContactTableNameTextFont,
    ContactTableInfoTextFont,
    ContactSendButtonTextFont
} AmbassadorFonts;

typedef enum ambassadorImages {
    RAFLogo
} AmbassadorImages;

typedef enum ambassadorSizes {
    // RAF
    ShareFieldHeight,
    ShareFieldCornerRadius
} AmbassadorSizes;

typedef enum socialShareTypes {
    Facebook,
    Twitter,
    LinkedIn,
    SMS,
    Email,
    None
} SocialShareTypes;

@interface AMBThemeManager : NSObject

+ (AMBThemeManager *)sharedInstance;
- (void)createDicFromPlist:(NSString*)plistName;
- (UIColor*)colorForKey:(AmbassadorColors)colorName;
- (NSString*)messageForKey:(AmbassadorMessages)messageName;
- (UIFont*)fontForKey:(AmbassadorFonts)fontName;
- (NSMutableDictionary*)imageForKey:(AmbassadorImages)imageName;
- (NSNumber*)sizeForKey:(AmbassadorSizes)sizeName;
- (NSArray*)customSocialGridArray;
+ (SocialShareTypes)enumValueForSocialString:(NSString*)string;

@end
