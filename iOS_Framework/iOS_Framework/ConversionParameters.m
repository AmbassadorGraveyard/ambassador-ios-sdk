//
//  ConversionParameters.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ConversionParameters.h"

@implementation ConversionParameters

#pragma mark - Initialization
- (id)init
{
    if ([super init])
    {
        self.mbsy_campaign = @-1;
        self.mbsy_email = @"";
        self.mbsy_first_name = @"";
        self.mbsy_last_name = @"";
        self.mbsy_email_new_ambassador = @0;
        self.mbsy_uid = @"";
        self.mbsy_custom1 = @"";
        self.mbsy_custom2 = @"";
        self.mbsy_custom3 = @"";
        self.mbsy_auto_create = @1;
        self.mbsy_revenue = @-1;
        self.mbsy_deactivate_new_ambassador = @0;
        self.mbsy_transaction_uid = @"";
        self.mbsy_add_to_group_id = @"";
        self.mbsy_event_data1 = @"";
        self.mbsy_event_data2 = @"";
        self.mbsy_event_data3 = @"";
        self.mbsy_is_approved = @1;
    }
    
    return self;
}



#pragma mark - Formatted printing
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ | %@ |",
            self.mbsy_campaign,
            self.mbsy_email,
            self.mbsy_first_name,
            self.mbsy_last_name,
            self.mbsy_email_new_ambassador,
            self.mbsy_uid,
            self.mbsy_custom1,
            self.mbsy_custom2,
            self.mbsy_custom3,
            self.mbsy_auto_create,
            self.mbsy_revenue,
            self.mbsy_deactivate_new_ambassador,
            self.mbsy_transaction_uid,
            self.mbsy_add_to_group_id,
            self.mbsy_event_data1,
            self.mbsy_event_data2,
            self.mbsy_event_data3,
            self.mbsy_is_approved];
}



#pragma mark - Validation
- (BOOL)isValid
{
    return [self.mbsy_campaign intValue] > -1 && ![self.mbsy_email isEqualToString:@""] && [self.mbsy_revenue intValue] > -1;
}

@end
