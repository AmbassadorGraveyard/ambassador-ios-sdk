//
//  AMBSecrets.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBSecrets.h"

@implementation AMBSecrets

// Creates a dictionary from a plist not included in repo
+ (NSDictionary *)secretsDictionary {
    NSBundle *ambassadorBundle = [NSBundle bundleForClass:[self class]];
    NSString *secretsPath = [ambassadorBundle pathForResource:@"AmbassadorSecrets" ofType:@"plist"];
    
    return [NSDictionary dictionaryWithContentsOfFile:secretsPath];
}

+ (NSString *)secretForKey:(AMBSecretKeys)key {
    NSDictionary *secretsDict = [AMBSecrets secretsDictionary];
    NSString *dictKey = [AMBSecrets stringForKey:key];
    NSString *returnString = secretsDict[dictKey] != nil ? secretsDict[dictKey] : @"Unavailable";
    
    return returnString;
}

// Function used to grab a string value for enum
+ (NSString *)stringForKey:(AMBSecretKeys)key {
    switch (key) {
        case AMB_PUSHER_DEV_KEY: return @"PUSHER_DEV_KEY";
        case AMB_PUSHER_PROD_KEY: return @"PUSHER_PROD_KEY";
        case AMB_SENTRY_KEY: return @"SENTRY_KEY";
        default: return @"Unavailable";
    }
}

@end
