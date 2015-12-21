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
+ (void)clearAmbUserDefaults;
+ (BOOL)isProduction;

// URLs
+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid;
+ (NSString*)getSendIdentifyUrl;

// Default setters
+ (void)setMbsyCookieWithCode:(NSString*)cookieCode;
+ (void)setDeviceFingerPrintWithDictionary:(NSDictionary*)dictionary;
+ (void)setHasInstalled;
+ (void)setUniversalIDWithID:(NSString*)universalID;
+ (void)setUniversalTokenWithToken:(NSString*)universalToken;
+ (void)setUserFirstNameWithString:(NSString*)firstName;
+ (void)setUserLastNameWithString:(NSString*)lastName;
+ (void)setLinkedInExpirationDate:(NSDate*)expirationDate;
+ (void)setLinkedInAccessToken:(NSString*)accessToken;

// Default getters
+ (NSString*)getMbsyCookieCode;
+ (NSDictionary*)getDeviceFingerPrint;
+ (BOOL)getHasInstalledBoolean;
+ (NSString*)getUniversalID;
+ (NSString*)getUniversalToken;
+ (NSString*)getUserFirstName;
+ (NSString*)getUserLastName;
+ (NSDate*)getLinkedInTokenExirationDate;
+ (NSString*)getLinkedInAccessToken;

@end
