//
//  ConversionParameters.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "ConversionParameters.h"
#import "Constants.h"
#import "Utilities.h"

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
- (NSError *)isValid;
{
    DLog(@"Inside Validation");
    NSError *e = nil;
    BOOL nonNil =   self.mbsy_campaign &&
                    self.mbsy_email &&
                    self.mbsy_first_name &&
                    self.mbsy_last_name &&
                    self.mbsy_email_new_ambassador &&
                    self.mbsy_uid &&
                    self.mbsy_custom1 &&
                    self.mbsy_custom2 &&
                    self.mbsy_custom3 &&
                    self.mbsy_auto_create &&
                    self.mbsy_revenue &&
                    self.mbsy_deactivate_new_ambassador &&
                    self.mbsy_transaction_uid &&
                    self.mbsy_add_to_group_id &&
                    self.mbsy_event_data1 &&
                    self.mbsy_event_data2 &&
                    self.mbsy_event_data3 &&
                    self.mbsy_is_approved;
    
    
    if (!nonNil)
    {
        DLog(@"Nil was passed for parameter");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"ConversionParameters Error", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"One of the ConversionParameter's properties was nil", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that all properties are being set to non-nil values. (Optional values are non-nil by default)", nil)
                                   };
        e = [NSError errorWithDomain:AMB_ERROR_DOMAIN code:ECPNIL userInfo:userInfo];
    }
    
    BOOL reqProps = [self.mbsy_campaign intValue] > -1 && ![self.mbsy_email isEqualToString:@""] && [self.mbsy_revenue intValue] > -1;
    
    if (!reqProps) {
        DLog(@"Req props was false");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"ConversionParameters Error", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"One of the required ConversionParameter properties was not set", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that 'mbsy_revenue', 'mbsy_email', and 'mbsy_campaign' properties are being set. (The other properties are optional", nil)
                                   };
        e = [NSError errorWithDomain:AMB_ERROR_DOMAIN code:ECPPROP userInfo:userInfo];
    }
    
    return e;
}

@end
