//
//  AMBOptions.h
//  Ambassador
//
//  Created by Diplomat on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#ifndef AMBOptions_h
#define AMBOptions_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AMBSocialServiceType) {
    AMBSocialServiceTypeTwitter,
    AMBSocialServiceTypeEmail,
    AMBSocialServiceTypeSMS,
    AMBSocialServiceTypeLinkedIn,
    AMBSocialServiceTypeFacebook
};

NSString* socialServiceTypeStringVal(AMBSocialServiceType type);

#endif /* AMBOptions_h */
