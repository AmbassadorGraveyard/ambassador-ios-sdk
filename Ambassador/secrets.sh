#!/bin/sh

cd Ambassador

echo #import "AMBSecrets.h"

echo @implementation AMBSecrets

echo NSString * PUSHER_DEV_KEY = @"$PUSHER_DEV_KEY";
echo NSString * PUSHER_PROD_KEY = @"$PUSHER_PROD_KEY";
echo NSString * SENTRY_KEY = @"$SENTRY_KEY";    

echo + (NSString *)secretForKey:(AMBSecretKeys)key {
echo     NSString *keyString = [self stringForKey:key];
echo     NSString *returnString = keyString != nil ? keyString : @"Unavailable";
    
echo     return returnString;
echo }

echo + (NSString *)stringForKey:(AMBSecretKeys)key {
echo     switch (key) {
echo         case AMB_PUSHER_DEV_KEY: return PUSHER_DEV_KEY;
echo         case AMB_PUSHER_PROD_KEY: return PUSHER_PROD_KEY;
echo         case AMB_SENTRY_KEY: return SENTRY_KEY;
echo         default: return @"Unavailable";
echo     }
echo }

echo @end
