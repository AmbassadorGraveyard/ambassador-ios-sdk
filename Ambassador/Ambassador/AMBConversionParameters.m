//
//  ConversionParameters.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBConversionParameters.h"
#import "AMBConstants.h"
#import "AMBConversionParameter_Internal.h"

@interface AMBConversionParameters ()

@property (nonatomic, strong) NSString * mbsy_short_code;
@property (nonatomic, strong) NSArray * propertyArray;

@end

@implementation AMBConversionParameters

#pragma mark - Initialization

- (id)init {
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
    self.mbsy_short_code = [AMBValues getMbsyCookieCode];
    
    // Sets an array of property names to easily loop through and check values
    self.propertyArray = @[@"mbsy_campaign", @"mbsy_email", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_email_new_ambassador", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3",
                           @"mbsy_auto_create", @"mbsy_revenue", @"mbsy_deactivate_new_ambassador", @"mbsy_transaction_uid", @"mbsy_add_to_group_id", @"mbsy_event_data1", @"mbsy_event_data2",
                           @"mbsy_event_data3", @"mbsy_is_approved"];
    
    return self;
}

- (id)initWithEntity:(AMBConversionParametersEntity *)entity {
    self.mbsy_campaign = entity.mbsy_campaign;
    self.mbsy_email = entity.mbsy_email;
    self.mbsy_first_name = entity.mbsy_first_name;
    self.mbsy_last_name = entity.mbsy_last_name;
    self.mbsy_email_new_ambassador = entity.mbsy_email_new_ambassador;
    self.mbsy_uid = entity.mbsy_uid;
    self.mbsy_custom1 = entity.mbsy_custom1;
    self.mbsy_custom2 = entity.mbsy_custom2;
    self.mbsy_custom3 = entity.mbsy_custom3;
    self.mbsy_auto_create = entity.mbsy_auto_create;
    self.mbsy_revenue = entity.mbsy_revenue;
    self.mbsy_deactivate_new_ambassador = entity.mbsy_deactivate_new_ambassador;
    self.mbsy_transaction_uid = entity.mbsy_transaction_uid;
    self.mbsy_add_to_group_id = entity.mbsy_add_to_group_id;
    self.mbsy_event_data1 = entity.mbsy_event_data1;
    self.mbsy_event_data2 = entity.mbsy_event_data2;
    self.mbsy_event_data3 = entity.mbsy_event_data3;
    self.mbsy_is_approved = entity.mbsy_is_approved;
    
    // Sets an array of property names to easily loop through and check values
    self.propertyArray = @[@"mbsy_campaign", @"mbsy_email", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_email_new_ambassador", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3",
                           @"mbsy_auto_create", @"mbsy_revenue", @"mbsy_deactivate_new_ambassador", @"mbsy_transaction_uid", @"mbsy_add_to_group_id", @"mbsy_event_data1", @"mbsy_event_data2",
                           @"mbsy_event_data3", @"mbsy_is_approved"];
    
    return self;
}


#pragma mark - Formatted printing

- (NSString *)description {
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSString *propertyString in self.propertyArray) {
        [string appendString:[NSString stringWithFormat:@"%@ = %@\n", propertyString, [self valueForKey:propertyString]]];
    }
    
    return string;
}

- (NSString*)getShortCode {
    return self.mbsy_short_code;
}


#pragma mark - Validation

- (NSError*)checkForError {
    NSError *error = nil;
    BOOL nonNil = YES;
    BOOL requiredPropertiesSet = [self.mbsy_campaign intValue] > -1 && ![self.mbsy_email isEqualToString:@""] && [self.mbsy_revenue intValue] > -1; // Boolean that checks that REQUIRED properties are set
    
    // Checks for any nil values
    for (NSString *propertyString in self.propertyArray) {
        if (![self valueForKey:propertyString]) {
            nonNil = NO;
            if ([self isStringProperty:propertyString]) {
                [self setValue:@"" forKey:propertyString];
            } else {
                [self setValue:@0 forKey:propertyString];
            }
        }
    }
    
    if (!nonNil) { NSLog(@"[Ambassador] Warning - ConversionPrameters object contained a nil property. Attempting to send anyway."); }
    
    if (!requiredPropertiesSet) {
        DLog(@"[Ambassador] Error - ConversionParameter's required properties were not set! Ensure that 'MBSY_REVENUE', 'MBSY_EMAIL', and 'MBSY_CAMPAIGN' properties are being set. (The other properties are optional");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"ConversionParameters Error", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"One of the required ConversionParameter properties was not set", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that 'mbsy_revenue', 'mbsy_email', and 'mbsy_campaign' properties are being set. (The other properties are optional", nil)};
        
        error = [NSError errorWithDomain:AMB_ERROR_DOMAIN code:ECPPROP userInfo:userInfo];
    }
    
    return error;
}


#pragma mark - Helper Functions

- (NSDictionary*)propertyDictionary {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    for (NSString *propertyString in self.propertyArray) {
        [mutableDict setValue:[self valueForKey:propertyString] forKey:propertyString];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (BOOL)isStringProperty:(NSString*)propertyName {
    NSArray *stringPropertyArray = @[@"mbsy_email", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3", @"mbsy_transaction_uid", @"mbsy_add_to_group_id",
                                     @"mbsy_event_data1", @"mbsy_event_data2", @"mbsy_event_data3"];
    
    for (NSString *currentStringProperties in stringPropertyArray) {
        if ([propertyName isEqualToString:currentStringProperties]) {
            return YES;
        }
    }
    
    return NO;
}

@end
