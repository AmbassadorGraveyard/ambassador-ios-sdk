//
//  DefaultsHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "DefaultsHandler.h"

@implementation DefaultsHandler


#pragma mark - Setters

+ (void)setSDKToken:(NSString*)sdkToken {
    [[NSUserDefaults standardUserDefaults] setObject:sdkToken forKey:@"SDK_TOKEN"];
}

+ (void)setUniversalID:(NSString*)univId {
    [[NSUserDefaults standardUserDefaults] setObject:univId forKey:@"UNIV_ID"];
}

+ (void)setFullName:(NSString*)firstName lastName:(NSString*)lastName {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"FULL_NAME"];
}

+ (void)setUserImage:(NSString*)imageUrl {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_IMAGE"];
}

+ (void)setThemeArray:(NSArray*)themeArray {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:themeArray];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"THEME_ARRAY"];
}


#pragma mark - Getters

+ (NSString*)getSDKToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_TOKEN"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_TOKEN"] : @"";
}

+ (NSString*)getUniversalID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UNIV_ID"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"UNIV_ID"] : @"";
}

+ (NSString*)getFullName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"FULL_NAME"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"FULL_NAME"] : @"";
}

+ (UIImage*)getUserImage {
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_IMAGE"];
    return [UIImage imageWithData:imageData];
}

+ (NSArray*)getThemeArray {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"THEME_ARRAY"];
    NSArray *returnArray = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return [[NSArray alloc] initWithArray:returnArray];
}


#pragma mark - Helper Functions

+ (void)clearUserValues {
    [DefaultsHandler setSDKToken:@""];
    [DefaultsHandler setUniversalID:@""];
    [DefaultsHandler setFullName:@"" lastName:@""];
    [DefaultsHandler setUserImage:@""];
}

@end
