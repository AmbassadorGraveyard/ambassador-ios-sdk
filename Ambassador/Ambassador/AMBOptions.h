//
//  AMBOptions.h
//  Ambassador
//
//  Created by Diplomat on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AMBSocialServiceType) {
    AMBSocialServiceTypeTwitter,
    AMBSocialServiceTypeEmail,
    AMBSocialServiceTypeSMS,
    AMBSocialServiceTypeLinkedIn,
    AMBSocialServiceTypeFacebook
};

@interface AMBOptions : NSObject

+ (NSString*)serviceTypeStringValue:(AMBSocialServiceType)type;

@end




