//
//  AMBErrors.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBErrors : NSObject

+ (void)conversionError:(NSInteger)statusCode errorData:(NSData*)data;
+ (void)errorNoMatchingCampaignIdError:(NSString*)campaignId;
+ (NSError*)restrictedConversionError;

@end


