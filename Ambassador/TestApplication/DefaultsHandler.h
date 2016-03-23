//
//  DefaultsHandler.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DefaultsHandler : NSObject

// SETTERS
+ (void)setSDKToken:(NSString*)sdkToken;
+ (void)setUniversalID:(NSString*)univId;
+ (void)setFullName:(NSString*)firstName lastName:(NSString*)lastName;
+ (void)setUserImage:(NSString*)imageUrl;
+ (void)setThemeArray:(NSMutableArray*)themeArray;
+ (void)setAddedDefaultRAFTrue;

// GETTERS
+ (NSString*)getSDKToken;
+ (NSString*)getUniversalID;
+ (NSString*)getFullName;
+ (UIImage*)getUserImage;
+ (NSMutableArray*)getThemeArray;
+ (BOOL)hasAddedDefault;

// HELPER FUNCTIONS
+ (void)clearUserValues;

@end
