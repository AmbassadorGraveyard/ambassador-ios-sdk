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
            break;
        case AMBSocialServiceTypeSMS:
            return @"sms";
            break;
        case AMBSocialServiceTypeTwitter:
            return @"twitter";
            break;
        case AMBSocialServiceTypeLinkedIn:
            return @"linkedin";
            break;
        case AMBSocialServiceTypeFacebook:
            return @"facebook";
            break;
        default:
            return nil;
            break;
    }
}

@end

