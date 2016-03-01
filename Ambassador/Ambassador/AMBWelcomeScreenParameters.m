//
//  AMBWelcomScreenParamets.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenParameters.h"

@interface AMBWelcomeScreenParameters()

@property (nonatomic, strong) NSString * referralMessage;
@property (nonatomic, strong) NSString * detailMessage;
@property (nonatomic, strong) NSString * actionButtonTitle;
@property (nonatomic, strong) NSArray * linkArray;

@end


@implementation AMBWelcomeScreenParameters


#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    self.referralMessage = @"You have been referred to this company";
    self.detailMessage = @"Welcome to our app!";
    self.linkArray = @[];
    
    return self;
}


#pragma mark - Setter Methods

- (void)setReferralMessage:(NSString *)referralMessage {
    self.referralMessage = referralMessage;
}

- (void)setDetailMessage:(NSString *)detailMessage {
    self.detailMessage = detailMessage;
}

- (void)setActionButtonTitle:(NSString *)actionButtonTitle {
    self.actionButtonTitle = actionButtonTitle;
}

- (void)setLinkArray:(NSArray *)linkArray {
    self.linkArray = linkArray;
}


#pragma mark - Getter Methods

- (NSString*)getReferralMessage {
    return self.referralMessage;
}

- (NSString*)getDetailMessage {
    return self.detailMessage;
}

- (NSString*)getActionButtonTitle {
    return self.actionButtonTitle;
}

- (NSArray*)getLinkArray {
    return self.linkArray;
}

@end
