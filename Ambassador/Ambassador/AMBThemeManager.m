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
    } else {
        // Checks to see if using GenericTheme or is using custom made theme from TestApplication which is prepended with AMBTESTAPP
        bundle = ([plistName isEqualToString:@"GenericTheme"] || [plistName containsString:@"AMBTESTAPP"]) ? ambassadorBundle : [NSBundle mainBundle];
    }

    // Grabs the plist path-- if the path doesn't exist, we default to use the Generic Theme from Ambassador Bundle
    NSString *plistPath = ([bundle pathForResource:plistName ofType:@"plist"]) ? [bundle pathForResource:plistName ofType:@"plist"] : [ambassadorBundle pathForResource:@"GenericTheme" ofType:@"plist"];
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
        
        [returnDict setValue:[UIImage imageNamed:[imageDescArray objectAtIndex:0]] forKey:@"image"];
  
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


#pragma mark - Helper Functions

- (BOOL)keyExists:(NSString*)keyName {
    return ([[valuesDic allKeys] containsObject:keyName] && ![[valuesDic valueForKey:keyName] isEqual: @""]) ? YES : NO;
}

@end
