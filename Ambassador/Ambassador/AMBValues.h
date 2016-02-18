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
#import "AMBPusherChannelObject.h"

@interface AMBValues : NSObject

+ (UIImage*)imageFromBundleWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable;
+ (NSBundle*)AMBframeworkBundle;
+ (BOOL)isProduction;

// URLs
+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid;
+ (NSString*)getSendIdentifyUrl;
+ (NSString*)getShareTrackUrl;
+ (NSString*)getLinkedInAuthorizationUrl;
+ (NSString*)getLinkedInAuthCallbackUrl;
+ (NSString*)getLinkedInRequestTokenUrl;
+ (NSString*)getLinkedInValidationUrl;
+ (NSString*)getLinkedInShareUrl;
+ (NSString*)getBulkShareSMSUrl;
+ (NSString*)getBulkShareEmailUrl;
+ (NSString*)getSendConversionUrl;
+ (NSString*)getPusherSessionUrl;
+ (NSString*)getPusherAuthUrl;

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
+ (void)setUserEmail:(NSString*)email;
+ (void)setPusherChannelObject:(NSDictionary*)pusherChannel;
+ (void)setUserURLObject:(NSDictionary*)urlObject;
+ (void)setAPNDeviceToken:(NSString*)deviceToken;
+ (void)resetHasInstalled; // Should only be used for TESTING

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
+ (NSString*)getUserEmail;
+ (AMBPusherChannelObject*)getPusherChannelObject;
+ (AMBUserUrlNetworkObject*)getUserURLObject;
+ (NSString*)getAPNDeviceToken;

@end
