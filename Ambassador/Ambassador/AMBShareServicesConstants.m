//
//  ShareServicesConstants.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBUtilities.h"

NSString * const AMB_FACEBOOK_TITLE = @"Facebook";
NSString * const AMB_FACEBOOK_LOGO_IMAGE = @"facebook";
UIColor * AMB_FACEBOOK_BACKGROUND_COLOR() { return AMBColorFromRGB(59, 89, 152); }
UIColor * AMB_FACEBOOK_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const AMB_TWITTER_TITLE = @"Twitter";
NSString * const AMB_TWITTER_LOGO_IMAGE = @"twitter";
UIColor * AMB_TWITTER_BACKGROUND_COLOR() { return AMBColorFromRGB(85, 172, 238); }
UIColor * AMB_TWITTER_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const AMB_LINKEDIN_TITLE = @"LinkedIn";
NSString * const AMB_LINKEDIN_LOGO_IMAGE = @"linkedin";
UIColor * AMB_LINKEDIN_BACKGROUND_COLOR() { return AMBColorFromRGB(0, 119, 181); }
UIColor * AMB_LINKEDIN_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const AMB_SMS_TITLE = @"SMS";
NSString * const AMB_SMS_LOGO_IMAGE = @"sms";
UIColor * AMB_SMS_BACKGROUND_COLOR() { return [UIColor clearColor]; }
UIColor * AMB_SMS_BORDER_COLOR() { return AMBColorFromRGB(170, 170, 170); }

NSString * const AMB_EMAIL_TITLE = @"Email";
NSString * const AMB_EMAIL_LOGO_IMAGE = @"email";
UIColor * AMB_EMAIL_BACKGROUND_COLOR() { return [UIColor clearColor]; }
UIColor * AMB_EMAIL_BORDER_COLOR() { return AMBColorFromRGB(170, 170, 170); }