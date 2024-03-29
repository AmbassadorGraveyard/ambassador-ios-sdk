//
//  AMBBulkShareHelper.h
//  Ambassador
//
//  Created by Jake Dunahee on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBOptions.h"

@interface AMBBulkShareHelper : NSObject

+ (NSMutableArray *)validatedEmails:(NSArray *)contacts;
+ (NSMutableArray *)validatedPhoneNumbers:(NSArray *)contacts;
+ (BOOL)isValidPhoneNumber:(NSString*)phoneNumber;
+ (BOOL)isValidEmail:(NSString*)emailAddress;
+ (NSString*)stripPhoneNumber:(NSString*)phoneNumber;
+ (NSArray*)shareTrackPayload:(NSArray*)contactList shareType:(AMBSocialServiceType)socialType;

@end
