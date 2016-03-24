//
//  UIColor+AMBColorValues.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/28/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "UIColor+AMBColorValues.h"

@implementation UIColor (AMBColorValues)

+ (UIColor*)twitterBlue {
    return [UIColor colorFromHexString:@"#469AE9"];
}

+ (UIColor*)faceBookBlue {
    return [UIColor colorFromHexString:@"#2E4486"];
}

+ (UIColor*)linkedInBlue {
    return [UIColor colorFromHexString:@"#0E62A6"];
}

+ (UIColor*)errorRed {
    return [UIColor colorFromHexString:@"#AE0015"];
}

+ (UIColor *)cellSelectionGray {
    return [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

@end
