//
//  AMBSMSHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/10/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBSMSHandler.h"

@implementation AMBSMSHandler

- (BOOL)alreadyHaveNames {
    NSString *firstName = [AMBValues getUserFirstName];
    NSString *lastName = [AMBValues getUserLastName];
    
    return ([firstName isEqualToString:@""] || [lastName isEqualToString:@""]) ? NO : YES;
}

@end
