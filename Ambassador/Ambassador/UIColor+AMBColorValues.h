//
//  UIColor+AMBColorValues.h
//  Ambassador
//
//  Created by Jake Dunahee on 10/28/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (AMBColorValues)

+ (UIColor*)twitterBlue;
+ (UIColor*)faceBookBlue;
+ (UIColor*)linkedInBlue;
+ (UIColor*)errorRed;
+ (UIColor*)cellSelectionGray;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
