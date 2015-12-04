//
//  AMBValues.h
//  Ambassador
//
//  Created by Jake Dunahee on 10/28/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AMBNetworkObject.h"

@interface AMBValues : NSObject

+ (UIImage*)imageFromBundleWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable;
+ (NSBundle*)AMBframeworkBundle;
+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid;
+ (void)clearAmbUserDefaults;

// Default setters
+ (void)setMbsyCookieWithCode:(NSString*)cookieCode;
+ (void)setDeviceFingerPrintWithDictionary:(NSDictionary*)dictionary;
+ (void)setUserFirstNameWithString:(NSString*)firstName;
+ (void)setUserLastNameWithString:(NSString*)lastName;

// Default getters
+ (NSString*)getMbsyCookieCode;
+ (NSDictionary*)getDeviceFingerPrint;
+ (NSString*)getUserFirstName;
+ (NSString*)getUserLastName;

@end
