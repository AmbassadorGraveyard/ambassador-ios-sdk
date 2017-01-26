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

extern NSString * TEST_APP_CONTSTANT;

+ (UIImage*)imageFromBundleWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable;
+ (NSBundle*)AMBframeworkBundle;
+ (BOOL)isProduction;
+ (BOOL)isUITestRun;

// URLs
+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid;
+ (NSString*)getSendIdentifyUrl;
+ (NSString*)getShareTrackUrl;
+ (NSString*)getLinkedInAuthorizationUrl;
+ (NSString*)getLinkedInShareUrlWithMessage:(NSString*)message;
+ (NSString*)getBulkShareSMSUrl;
+ (NSString*)getBulkShareEmailUrl;
+ (NSString*)getSendConversionUrl;
+ (NSString*)getPusherSessionUrl;
+ (NSString*)getPusherAuthUrl;
+ (NSString*)getSentryDSNValue;
+ (NSString*)getCompanyDetailsUrl;
+ (NSString*)getLinkedinClientValuesUrl:(NSString*)clientUID;
+ (NSString*)getLinkedinAccessTokenUrl:(NSString*)popupValue;
+ (NSString*)getReferrerInformationUrl;

// Default setters
+ (void)setMbsyCookieWithCode:(NSString*)cookieCode;
+ (void)setMbsyCampaign:(NSString*)campaignID;
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
+ (void)setUserCampaignList:(AMBUserNetworkObject *)userObject;
+ (void)setAPNDeviceToken:(NSString*)deviceToken;
+ (void)setLinkedInClientID:(NSString*)clientID;
+ (void)setLinkedInClientSecret:(NSString*)clientSecret;
+ (void)setUserIdentifyObject:(AMBIdentifyNetworkObject *)identifyObject;
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
+ (NSString*)getMbsyCampaign;
+ (AMBPusherChannelObject*)getPusherChannelObject;
+ (AMBUserUrlNetworkObject*)getUserURLObject;
+ (AMBUserNetworkObject *)getUserCampaignList;
+ (NSString*)getAPNDeviceToken;
+ (NSString*)getLinkedInClientID;
+ (NSString*)getLinkedInClientSecret;
+ (AMBIdentifyNetworkObject *)getUserIdentifyObject;

@end
