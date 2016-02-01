//
//  AMBOptions.m
//  Ambassador
//
//  Created by Diplomat on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBOptions.h"

@implementation AMBOptions

+ (NSString*)serviceTypeStringValue:(AMBSocialServiceType)type {
    switch (type) {
        case AMBSocialServiceTypeEmail:
            return @"email";
        case AMBSocialServiceTypeSMS:
            return @"sms";
        case AMBSocialServiceTypeTwitter:
            return @"twitter";
        case AMBSocialServiceTypeLinkedIn:
            return @"linkedin";
        case AMBSocialServiceTypeFacebook:
            return @"facebook";
        default:
            return nil;
    }
}

@end

