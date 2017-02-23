//
//  AMBThemeManager.m
//  Ambassador
//
//  Created by Jake Dunahee on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMBThemeManager.h"


@implementation AMBThemeManager

static NSDictionary * valuesDic;

#pragma mark - LifeCycle

+ (AMBThemeManager *)sharedInstance
{
    static AMBThemeManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBThemeManager alloc] init];
    });
    
    return _sharedInsance;
}

- (void)createDicFromPlist:(NSString*)plistName {
    NSBundle *bundle = nil;
    NSBundle *ambassadorBundle = [NSBundle bundleWithIdentifier:@"AmbassadorBundle"];
    
    // Checks to is running unit tests, which will use the unit test bundle
    if (NSClassFromString(@"XCTest")) {
        bundle = [NSBundle bundleForClass:[self class]];
    // Makes sure that the plist is not a custom made theme from the Test Application -- we WONT use a bundle is that is the case
    } else if (![plistName containsString:TEST_APP_CONTSTANT]) {
        // Checks to see if using GenericTheme
        bundle = ([plistName isEqualToString:@"GenericTheme"]) ? ambassadorBundle : [NSBundle mainBundle];
    }

    // Grabs the plist path-- if the path doesn't exist, we default to use the Generic Theme from Ambassador Bundle
    NSString *plistPath;
    
    if (bundle) {
        plistPath = ([bundle pathForResource:plistName ofType:@"plist"]) ? [bundle pathForResource:plistName ofType:@"plist"] : [ambassadorBundle pathForResource:@"GenericTheme" ofType:@"plist"];
    } else {
        // Must mean that the theme was created from within the Test Application and will grab from the Documents folder if exists -- else use Generic Theme
        plistPath = ([self getDocumentsPathWithName:plistName]) ? [self getDocumentsPathWithName:plistName] : [ambassadorBundle pathForResource:@"GenericTheme" ofType:@"plist"];
    }
    
    valuesDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}


#pragma mark - Colors

- (UIColor*)colorForKey:(AmbassadorColors)colorName {
    if ([self keyExists:[self colorEnumStringValue:colorName]]) {
        return ([UIColor colorFromHexString:[valuesDic valueForKey:[self colorEnumStringValue:colorName]]]) ? [UIColor colorFromHexString:[valuesDic valueForKey:[self colorEnumStringValue:colorName]]] : [UIColor whiteColor];
    }
    
    return [UIColor whiteColor];
}

- (NSString*)colorEnumStringValue:(AmbassadorColors)enumValue {
    switch (enumValue) {
        case NavBarColor:
            return @"NavBarColor";
            break;
        case NavBarTextColor:
            return @"NavBarTextColor";
            break;
        case RAFBackgroundColor:
            return @"RAFBackgroundColor";
            break;
        case RAFWelcomeTextColor:
            return @"RAFWelcomeTextColor";
            break;
        case RAFDescriptionTextColor:
            return @"RAFDescriptionTextColor";
            break;
        case ContactSendButtonBackgroundColor:
            return @"ContactSendButtonBackgroundColor";
            break;
        case ContactSendButtonTextColor:
            return @"ContactSendButtonTextColor";
            break;
        case ContactSearchBackgroundColor:
            return @"ContactSearchBackgroundColor";
            break;
        case ContactSearchDoneButtonTextColor:
            return @"ContactSearchDoneButtonTextColor";
            break;
        case ContactTableCheckMarkColor:
            return @"ContactTableCheckMarkColor";
            break;
        case ContactAvatarBackgroundColor:
            return @"ContactAvatarBackgroundColor";
        case ContactAvatarColor:
            return @"ContactAvatarColor";
        case ShareFieldBackgroundColor:
            return @"ShareFieldBackgroundColor";
        case ShareFieldTextColor:
            return @"ShareFieldTextColor";
        case AlertButtonBackgroundColor:
            return @"AlertButtonBackgroundColor";
        case AlertButtonTextColor:
            return @"AlertButtonTextColor";
        case ContactTableBackgroundColor:
            return @"ContactTableBackgroundColor";
        case ContactTableNameTextColor:
            return @"ContactTableNameTextColor";
        case ContactTableInfoTextColor:
            return @"ContactTableInfoTextColor";
        default:
            return @"Unavailable";
            break;
    }
}


#pragma mark - Messages

- (NSString*)messageForKey:(AmbassadorMessages)messageName {
    if ([self keyExists:[self messageEnumStringValue:messageName]]) {
        return [valuesDic valueForKey:[self messageEnumStringValue:messageName]];
    }
    
    return @"NO PLIST VALUE FOUND";
}

- (NSString*)messageEnumStringValue:(AmbassadorMessages)enumValue {
    switch (enumValue) {
        case NavBarTextMessage:
            return @"NavBarTextMessage";
            break;
        case RAFWelcomeTextMessage:
            return @"RAFWelcomeTextMessage";
            break;
        case RAFDescriptionTextMessage:
            return @"RAFDescriptionTextMessage";
            break;
        case DefaultShareMessage:
            return @"DefaultShareMessage";
            break;
        case LandingPageMessage:
            return @"LandingPageMessage";
            break;
        case LandingPageBackgroundColor:
            return @"LandingPageBackgroundColor";
            break;
        default:
            return @"Unavailable";
            break;
    }
}


#pragma mark - Fonts

- (UIFont*)fontForKey:(AmbassadorFonts)fontName {
    if ([self keyExists:[self fontEnumStringValue:fontName]]) {
        NSString *fontDescription = [valuesDic valueForKey:[self fontEnumStringValue:fontName]];
        NSArray *fontArray = [fontDescription componentsSeparatedByString:@","];
        
        NSString *fontName = fontArray[0];
        NSString *fontSizeString;
        CGFloat fontSize = 14;
        
        if (fontArray.count > 1) {
            fontSizeString = fontArray[1];
            fontSize = [fontSizeString floatValue];
        }

        return ([UIFont fontWithName:fontName size:fontSize]) ? [UIFont fontWithName:fontName size:fontSize] : [UIFont systemFontOfSize:14];
    }
    
    return [UIFont systemFontOfSize:11];
}

- (NSString*)fontEnumStringValue:(AmbassadorFonts)enumValue {
    switch (enumValue) {
        case NavBarTextFont:
            return @"NavBarTextFont";
            break;
        case RAFWelcomeTextFont:
            return @"RAFWelcomeTextFont";
            break;
        case RAFDescriptionTextFont:
            return @"RAFDescriptionTextFont";
            break;
        case ContactTableNameTextFont:
            return @"ContactTableNameTextFont";
            break;
        case ContactTableInfoTextFont:
            return @"ContactTableInfoTextFont";
            break;
        case ContactSendButtonTextFont:
            return @"ContactSendButtonTextFont";
            break;
        case ShareFieldTextFont:
            return @"ShareFieldTextFont";
        default:
            return @"Unavailable";
            break;
    }
}


#pragma mark - Images

- (NSMutableDictionary*)imageForKey:(AmbassadorImages)imageName {
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    [returnDict setValue:@"0" forKey:@"imageSlotNumber"];
    [returnDict setValue:[[UIImage alloc] init] forKey: @"image"];
    
    if ([self keyExists:[self imageEnumStringValue:imageName]]) {
        NSString *imageDescription = [valuesDic valueForKey:[self imageEnumStringValue:imageName]];
        NSArray *imageDescArray = [imageDescription componentsSeparatedByString:@","];
        
        // Grabs image name from plist
        NSString *imageName = [imageDescArray objectAtIndex:0];
        
        /* Checks if customized RAF from Test App.
        If it is a custom RAF from the test app
        then we grab the image from the documents folder.
        Else, we will grab from the parent's image 
        assets folder as usual. */
        UIImage *returnImage = ([imageName containsString:TEST_APP_CONTSTANT]) ? [UIImage imageWithContentsOfFile:[self getImagePathWithName:imageName]] : [UIImage imageNamed:imageName];
        [returnDict setValue:returnImage forKey:@"image"];
  
        if (imageDescArray.count > 1) {
            [returnDict setValue:[imageDescArray objectAtIndex:1] forKey:@"imageSlotNumber"];
        }
    }
    
    return returnDict;
}

- (NSString*)imageEnumStringValue:(AmbassadorImages)enumValue {
    switch (enumValue) {
        case RAFLogo:
            return @"RAFLogo";
            break;
        default:
            return @"Unavailable";
            break;
    }
}


#pragma mark - Sizes

- (NSNumber*)sizeForKey:(AmbassadorSizes)sizeName {
    if ([self keyExists:[self sizeEnumStringValue:sizeName]]) {
        return [valuesDic valueForKey:[self sizeEnumStringValue:sizeName]];
    } else {
        return 0;
    }
}

- (NSString*)sizeEnumStringValue:(AmbassadorSizes)enumValue {
    switch (enumValue) {
        case ShareFieldHeight:
            return @"ShareFieldHeight";
            break;
        case ShareFieldCornerRadius:
            return @"ShareFieldCornerRadius";
            break;
        default:
            break;
    }
}


#pragma mark - Ordering

- (NSArray*)customSocialGridArray {
    NSString *arrayString = [[[valuesDic valueForKey:@"Channels"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return (![arrayString isEqualToString:@""]) ? [[arrayString stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","] : @[];
}

+ (SocialShareTypes)enumValueForSocialString:(NSString*)string {
    if ([string isEqualToString:@"facebook"]) {
        return Facebook;
    } else if ([string isEqualToString:@"twitter"]) {
        return Twitter;
    } else if ([string isEqualToString:@"linkedin"]) {
        return LinkedIn;
    } else if ([string isEqualToString:@"sms"]) {
        return SMS;
    } else if ([string isEqualToString:@"email"]) {
        return Email;
    } else {
        return None;
    }
}


#pragma mark - Status Bar

- (UIStatusBarStyle)statusBarTheme {
    // Key for boolean
    NSString *key = @"UseDarkStatusBarTheme";
    
    // Get Bool value from plist
    BOOL useDarkTheme = [self keyExists:key] ? [[valuesDic valueForKey:key] boolValue] : YES;
    
    return useDarkTheme ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}


#pragma mark - Helper Functions

- (BOOL)keyExists:(NSString*)keyName {
    return ([[valuesDic allKeys] containsObject:keyName] && ![[valuesDic valueForKey:keyName] isEqual: @""]) ? YES : NO;
}

- (NSString*)getDocumentsPathWithName:(NSString*)themeName {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", themeName]];
    return filePath;
}

- (NSString*)getImagePathWithName:(NSString*)imageName {
    // Gets Documents folder directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Gets image from documents folder
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    return filePath;
}

@end
