//
//  AMBSecrets.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ambSecretKeys {
    AMB_PUSHER_DEV_KEY,
    AMB_PUSHER_PROD_KEY,
    AMB_SENTRY_KEY
} AMBSecretKeys;


@interface AMBSecrets : NSObject

+ (NSString *)secretForKey:(AMBSecretKeys)key;

@end
