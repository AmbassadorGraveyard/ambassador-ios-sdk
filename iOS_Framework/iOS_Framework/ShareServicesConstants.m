//
//  ShareServicesConstants.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

NSString * const FACEBOOK_TITLE = @"Facebook";
NSString * const FACEBOOK_LOGO_IMAGE = @"facebook.png";
UIColor * FACEBOOK_BACKGROUND_COLOR() { return ColorFromRGB(59, 89, 152); }
UIColor * FACEBOOK_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const TWITTER_TITLE = @"Twitter";
NSString * const TWITTER_LOGO_IMAGE = @"twitter.png";
UIColor * TWITTER_BACKGROUND_COLOR() { return ColorFromRGB(85, 172, 238); }
UIColor * TWITTER_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const LINKEDIN_TITLE = @"LinkedIn";
NSString * const LINKEDIN_LOGO_IMAGE = @"linkedin.png";
UIColor * LINKEDIN_BACKGROUND_COLOR() { return ColorFromRGB(0, 119, 181); }
UIColor * LINKEDIN_BORDER_COLOR() { return [UIColor clearColor]; }

NSString * const SMS_TITLE = @"SMS";
NSString * const SMS_LOGO_IMAGE = @"sms.png";
UIColor * SMS_BACKGROUND_COLOR() { return [UIColor clearColor]; }
UIColor * SMS_BORDER_COLOR() { return ColorFromRGB(170, 170, 170); }

NSString * const EMAIL_TITLE = @"Email";
NSString * const EMAIL_LOGO_IMAGE = @"email.png";
UIColor * EMAIL_BACKGROUND_COLOR() { return [UIColor clearColor]; }
UIColor * EMAIL_BORDER_COLOR() { return ColorFromRGB(170, 170, 170); }