//
//  AMBWelcomScreenParamets.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBWelcomeScreenParameters : NSObject

- (void)setReferralMessage:(NSString *)referralMessage;
- (void)setDetailMessage:(NSString *)detailMessage;
- (void)setActionButtonTitle:(NSString *)actionButtonTitle;
- (void)setLinkArray:(NSArray *)linkArray;

@end
