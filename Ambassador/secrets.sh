#!/bin/sh

cd Ambassador

echo " #import "AMBSecrets.h"" >> AMBSecrets.m

echo "@implementation AMBSecrets" >> AMBSecrets.m

echo "NSString * PUSHER_DEV_KEY = @"$PUSHER_DEV_KEY";" >> AMBSecrets.m
echo "NSString * PUSHER_PROD_KEY = @"$PUSHER_PROD_KEY";" >> AMBSecrets.m
echo "NSString * SENTRY_KEY = @"$SENTRY_KEY";" >> AMBSecrets.m

echo "+ (NSString *)secretForKey:(AMBSecretKeys)key {" >> AMBSecrets.m
echo "    NSString *keyString = [self stringForKey:key];" >> AMBSecrets.m
echo "    NSString *returnString = keyString != nil ? keyString : @"Unavailable";" >> AMBSecrets.m
    
echo "    return returnString;" >> AMBSecrets.m
echo "}" >> AMBSecrets.m

echo "+ (NSString *)stringForKey:(AMBSecretKeys)key {" >> AMBSecrets.m
echo "    switch (key) {" >> AMBSecrets.m
echo "        case AMB_PUSHER_DEV_KEY: return PUSHER_DEV_KEY;" >> AMBSecrets.m
echo "        case AMB_PUSHER_PROD_KEY: return PUSHER_PROD_KEY;" >> AMBSecrets.m
echo "        case AMB_SENTRY_KEY: return SENTRY_KEY;" >> AMBSecrets.m
echo "        default: return @"Unavailable";" >> AMBSecrets.m
echo "    }" >> AMBSecrets.m
echo "}" >> AMBSecrets.m

echo "@end" >> AMBSecrets.m
