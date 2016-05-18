#!/bin/sh

cd Ambassador

echo #import "AMBSecrets.h"

echo @implementation AMBSecrets

echo NSString const * PUSHER_DEV_KEY = @"$PUSHER_DEV_KEY";
echo NSString const * PUSHER_PROD_KEY = @"$PUSHER_PROD_KEY";
echo NSString const * SENTRY_KEY = @"$SENTRY_KEY";

echo + (NSDictionary *)secretsDictionary {
echo     NSBundle *ambassadorBundle = [NSBundle bundleForClass:[self class]];
echo     NSString *secretsPath = [ambassadorBundle pathForResource:@"AmbassadorSecrets" ofType:@"plist"];
    
echo     return [NSDictionary dictionaryWithContentsOfFile:secretsPath];
echo }

echo + (NSString *)secretForKey:(AMBSecretKeys)key {
echo     NSDictionary *secretsDict = [AMBSecrets secretsDictionary];
echo     NSString *dictKey = [AMBSecrets stringForKey:key];
echo     NSString *returnString = secretsDict[dictKey] != nil ? secretsDict[dictKey] : @"Unavailable";
    
echo     return returnString;
echo }

echo + (NSString *)stringForKey:(AMBSecretKeys)key {
echo     switch (key) {
echo         case AMB_PUSHER_DEV_KEY: return @"PUSHER_DEV_KEY";
echo         case AMB_PUSHER_PROD_KEY: return @"PUSHER_PROD_KEY";
echo         case AMB_SENTRY_KEY: return @"SENTRY_KEY";
echo         default: return @"Unavailable";
echo     }
echo }

echo @end
