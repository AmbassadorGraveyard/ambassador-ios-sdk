//
//  AMBWelcomeScreenParameters_Internal.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenParameters"
#import <Foundation/Foundation.h>

@interface AMBWelcomScreenParameters()

- (NSString*)getReferralMessage;
- (NSString*)getDetailMessage
- (NSString*)getActionButtonTitle;
- (NSArray*)getLinkArray;

@end
