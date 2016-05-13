//
//  ConversionParameters.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBConversionParameters.h"
#import "AMBConversionParameter_Internal.h"

@interface AMBConversionParameters ()

@property (nonatomic, strong) NSString * mbsy_short_code;

@end

@implementation AMBConversionParameters

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
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
        [self setUpPropertyArray];
    }
    
    return self;
}

- (id)initWithEntity:(AMBConversionParametersEntity *)entity {
    if (self = [super init]) {
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
        [self setUpPropertyArray];
    }
    
    return self;
}

- (instancetype)initWithProperties:(NSDictionary *)properties {
    if (self = [super init]) {
        NSString *blankString = @"";
        
        self.mbsy_email = [AMBValues getUserEmail];
        self.mbsy_campaign = properties[@"campaign"] ? properties[@"campaign"] : blankString;
        self.mbsy_revenue = properties[@"revenue"] ? properties[@"revenue"] : blankString;
        self.mbsy_is_approved = properties[@"commissionApproved"] ? properties[@"commissionApproved"] : blankString;
        self.mbsy_event_data1 = properties[@"eventData1"] ? properties[@"eventData1"] : blankString;
        self.mbsy_event_data2 = properties[@"eventData2"] ? properties[@"eventData2"] : blankString;
        self.mbsy_event_data3 = properties[@"eventData3"] ? properties[@"eventData3"] : blankString;
        self.mbsy_transaction_uid = properties[@"orderId"] ? properties[@"orderId"] : blankString;
        [self setUpPropertyArray];
    }
    
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
            if ([AMBConversionParameters isStringProperty:propertyString]) {
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
        
        error = [NSError errorWithDomain:@"AmbassadorSDKErrorDomain" code:0 userInfo:userInfo];
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

+ (BOOL)isStringProperty:(NSString*)propertyName {
    NSArray *stringPropertyArray = @[@"mbsy_email", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3", @"mbsy_transaction_uid", @"mbsy_add_to_group_id",
                                     @"mbsy_event_data1", @"mbsy_event_data2", @"mbsy_event_data3"];
    
    for (NSString *currentStringProperties in stringPropertyArray) {
        if ([propertyName isEqualToString:currentStringProperties]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isBoolProperty:(NSString*)propertyName {
    NSArray *boolPropertyArray = @[@"mbsy_email_new_ambassador", @"mbsy_auto_create", @"mbsy_deactivate_new_ambassador", @"mbsy_is_approved"];
    
    for (NSString *boolProperty in boolPropertyArray) {
        if ([propertyName isEqualToString:boolProperty]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setUpPropertyArray {
    // Sets an array of property names to easily loop through and check values
    self.propertyArray = @[@"mbsy_campaign", @"mbsy_email",  @"mbsy_revenue", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_email_new_ambassador", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3",
                           @"mbsy_auto_create", @"mbsy_deactivate_new_ambassador", @"mbsy_transaction_uid", @"mbsy_add_to_group_id", @"mbsy_event_data1", @"mbsy_event_data2",
                           @"mbsy_event_data3", @"mbsy_is_approved"];
}


#pragma mark - Custom Setters

/*
 These custom setters are to insure that boolean values get 
 converted into ints.
 */
- (void)setMbsy_is_approved:(NSNumber *)mbsy_is_approved {
    _mbsy_is_approved = [NSNumber numberWithInt:[mbsy_is_approved intValue]];
}

- (void)setMbsy_email_new_ambassador:(NSNumber *)mbsy_email_new_ambassador {
    _mbsy_email_new_ambassador = [NSNumber numberWithInt:[mbsy_email_new_ambassador intValue]];
}

- (void)setMbsy_auto_create:(NSNumber *)mbsy_auto_create {
    _mbsy_auto_create = [NSNumber numberWithInt:[mbsy_auto_create intValue]];;
}

- (void)setMbsy_deactivate_new_ambassador:(NSNumber *)mbsy_deactivate_new_ambassador {
    _mbsy_deactivate_new_ambassador = [NSNumber numberWithInt:[_mbsy_auto_create intValue]];
}

- (void)setMbsy_revenue:(NSNumber *)mbsy_revenue {
    NSString *decimalString = [NSString stringWithFormat:@"%.02f", [mbsy_revenue floatValue]];
    _mbsy_revenue = [NSNumber numberWithFloat:[decimalString floatValue]];
}

@end
