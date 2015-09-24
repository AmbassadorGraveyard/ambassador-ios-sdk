//
//  AMBThemeManager.m
//  Ambassador
//
//  Created by Jake Dunahee on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBThemeManager.h"

typedef enum ambassadorColors {
    NavBarColor
} AmbassadorColors;

@implementation AMBThemeManager

+ (AMBThemeManager *)sharedInstance
{
    static AMBThemeManager* _sharedInsance = nil;
    static NSDictionary * valuesDic;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[AMBThemeManager alloc] init];
    });
    
    [AMBThemeManager sharedInstance].valuesDic = [_sharedInsance createDicFromPlist];
    
    return _sharedInsance;
}

- (NSDictionary*)createDicFromPlist {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"AmbassadorBundle"];
    NSString *plistPath = [bundle pathForResource:@"AmbassadorTheme" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

+ (UIColor*)colorForKey:(AmbassadorColors)colorName {
    if ([[[AMBThemeManager sharedInstance].valuesDic allKeys] containsObject:[AMBThemeManager enumStringValue:colorName]]) {
        return [AMBThemeManager colorFromHexString:[[AMBThemeManager sharedInstance].valuesDic valueForKey:[AMBThemeManager enumStringValue:colorName]]];
    }
    
    return [UIColor whiteColor];
}

+ (NSString*)enumStringValue:(int)enumValue {
    switch (enumValue) {
        case 0:
            return @"NavBarColor";
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
