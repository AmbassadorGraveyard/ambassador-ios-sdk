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

+ (AMBThemeManager *)sharedInstance
{
    static AMBThemeManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBThemeManager alloc] init];
        valuesDic = [AMBThemeManager createDicFromPlist];
    });
    
    
    
    return _sharedInsance;
}

+ (NSDictionary*)createDicFromPlist {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"AmbassadorBundle"];
    NSString *plistPath = [bundle pathForResource:@"AmbassadorTheme" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

- (UIColor*)colorForKey:(AmbassadorColors)colorName {
    if ([[valuesDic allKeys] containsObject:[AMBThemeManager colorEnumStringValue:colorName]] && ![[valuesDic valueForKey:[AMBThemeManager colorEnumStringValue:colorName]] isEqual: @""]) {
        return ([AMBThemeManager colorFromHexString:[valuesDic valueForKey:[AMBThemeManager colorEnumStringValue:colorName]]]) ? [AMBThemeManager colorFromHexString:[valuesDic valueForKey:[AMBThemeManager colorEnumStringValue:colorName]]] : [UIColor whiteColor];
    }
    
    return [UIColor lightGrayColor];
}

- (NSString*)messageForKey:(AmbassadorMessages)messageName {
    if ([[valuesDic allKeys] containsObject:[AMBThemeManager messageEnumStringValue:messageName]] && ![[valuesDic valueForKey:[AMBThemeManager messageEnumStringValue:messageName]] isEqualToString:@""]) {
        return [valuesDic valueForKey:[AMBThemeManager messageEnumStringValue:messageName]];
    }
    
    return @"NO PLIST VALUE FOUND";
}

- (UIFont*)fontForKey:(AmbassadorFonts)fontName {
    if ([[valuesDic allKeys] containsObject:[AMBThemeManager fontEnumStringValue:fontName]] && ![[valuesDic valueForKey:[AMBThemeManager fontEnumStringValue:fontName]] isEqualToString:@""]) {
        NSString *fontDescription = [valuesDic valueForKey:[AMBThemeManager fontEnumStringValue:fontName]];
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

- (UIImage*)imageForKey:(AmbassadorImages)imageName {
    if ([[valuesDic allKeys] containsObject:[AMBThemeManager imageEnumStringValue:imageName]] && ![[valuesDic valueForKey:[AMBThemeManager imageEnumStringValue:imageName]] isEqualToString:@""]) {
        
        return [UIImage imageNamed:[valuesDic valueForKey:[AMBThemeManager imageEnumStringValue:imageName]]];
    }
    
    return [[UIImage alloc] init];
}

+ (NSString*)colorEnumStringValue:(AmbassadorColors)enumValue {
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

        default:
            return @"Unavailable";
            break;
    }
}

+ (NSString*)messageEnumStringValue:(AmbassadorMessages)enumValue {
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

+ (NSString*)fontEnumStringValue:(AmbassadorFonts)enumValue {
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
            
        default:
            return @"Unavailable";
            break;
    }
}

+ (NSString*)imageEnumStringValue:(AmbassadorImages)enumValue {
    switch (enumValue) {
        case RAFLogo:
            return @"RAFLogo";
            break;
            
        default:
            return @"Unavailable";
            break;
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
