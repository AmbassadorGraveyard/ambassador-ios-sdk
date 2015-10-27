//
//  AMBBulkShareHelper.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBBulkShareHelper.h"
#import "AMBContact.h"

@implementation AMBBulkShareHelper

+ (NSMutableArray *)validateEmails:(NSArray *)contacts {
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    
    for (AMBContact *contact in contacts)
    {
        NSString *number = contact.value;
        [validSet addObject:number];
    }
    
    return validSet;
}

@end
