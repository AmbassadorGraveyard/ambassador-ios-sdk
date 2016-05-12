//
//  Conversion.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBConversion.h"
#import "AMBCoreDataManager.h"
#import "AMBConversionParametersEntity.h"
#import "AMBConversionParameter_Internal.h"
#import "AMBNetworkManager.h"
#import "AMBErrors.h"


@implementation AMBConversion


#pragma mark - API Functions

- (void)registerConversionWithParameters:(AMBConversionParameters *)parameters success:(void(^)(AMBConversionParameters *conversion))success pending:(void(^)(AMBConversionParameters *conversion))pending error:(void(^)(NSError *error, AMBConversionParameters *conversion))error {
    // Checks to see if there is an error with the ConversionParameters object's properties
    NSError *conversionError = [parameters checkForError];
    
    // If there is an error with the object we return the error
    if (conversionError) {
        if (error) { error(conversionError, parameters); }
        return;
    }
    
    // If the conversion is unable to send because no fp or short_code we return 'pending'
    if (![self canSendConversion]) {
        // Save the conversion to the database for later sending
        [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]];
        if (pending) { pending(parameters); }
        return;
    }
    
    // If there is no error with the object and we have the fp/short_code, we send it
    [self sendConversion:parameters success:^{
        if (success) { success(parameters); }
    } failure:^{
        // If the call fails at this point, we can assume it's a network issue and will save it for later
        if (pending) { pending(parameters); }
    }];
}

- (void)retryUnsentConversions {
    // Checks to see if we have fp/short_code
    if (![self canSendConversion]) {
        return;
    }
    
    // Grabs all of the conversion objects stored in the coredata DB
    NSArray *storedConversionArray = [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:@"AMBConversionParametersEntity"];
    
    // Make sure that there are conversions that need to sent off
    if ([storedConversionArray count] > 0) {
        
        // Loop through all unsent conversions to send
        for (AMBConversionParametersEntity *entity in storedConversionArray) {
            // Creates a parameter object from the coredata entity and sends it off
            AMBConversionParameters *parameters = [[AMBConversionParameters alloc] initWithEntity:entity];
            [self sendConversion:parameters success:^{
                DLog(@"Conversion retry success - %@", parameters);
                
                // Deletes the coredata object after successful send
                [AMBCoreDataManager deleteCoreDataObject:entity];
            } failure:^{
                DLog(@"Conversion retry failed - %@", parameters);
            }];
        }
    } 
}

- (void)sendConversion:(AMBConversionParameters *)parameters success:(void(^)())success failure:(void(^)())failure {
    // Gets the device fingerprint
    NSDictionary *identifyInfo = [AMBValues getDeviceFingerPrint];
    
    // Creates a mutable dictionary rom the parameter object's property dictionary
    NSMutableDictionary *fieldsDictionary = [[parameters propertyDictionary] mutableCopy];
    [fieldsDictionary setValue:[AMBValues getMbsyCookieCode] forKey:@"mbsy_short_code"];
    
    // Creates the payload to send in the POST body
    NSDictionary *payloadDict = [self payloadForConversionCallWithFP:identifyInfo mbsyFields:fieldsDictionary];
    
    // Make network call to send off our conversion
    [[AMBNetworkManager sharedInstance] sendRegisteredConversion:payloadDict success:^(NSDictionary *response) {
        DLog(@"Conversion Send Success - %@", response);
        
        // Call the success block if there is one
        if (success) { success(); }
    } failure:^(NSInteger statusCode, NSData *data) {
        [AMBErrors errorLogCannotSendConversion:statusCode errorData:data];
        
        // Saves AMBConversionParameter object to the database without the mbsy_short_code value, because it is manually added on later
        [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]];
        
        // Call the failure block if there is one
        if (failure) { failure(); }
    }];
}


#pragma mark - Helper Functions

- (NSDictionary*)payloadForConversionCallWithFP:(NSDictionary*)deviceFingerprint mbsyFields:(NSMutableDictionary*)mbsyFields {
    // If we DON'T have a device fingerprint, we set the 'fp' value to empty set the fields to the mbsy fields
    if (!deviceFingerprint || deviceFingerprint.count == 0) { return @{@"fp" : @{}, @"fields" : mbsyFields}; }
    
    NSDictionary *consumerDict = @{@"UID" : deviceFingerprint[@"consumer"][@"UID"], @"insights" : (deviceFingerprint[@"consumer"][@"insights"]) ? deviceFingerprint[@"consumer"][@"insights"] : @{}};
    NSDictionary *deviceDict = @{@"type" : deviceFingerprint[@"device"][@"type"], @"ID" : deviceFingerprint[@"device"][@"ID"]};
    NSDictionary *fingerPrintDict = @{@"consumer" : consumerDict, @"device" : deviceDict };
    
    return @{@"fp" : fingerPrintDict, @"fields" : mbsyFields };
}

- (BOOL)canSendConversion {
    // If no device fingerprint is available, an empty dictionary will be returned
    NSDictionary *userDefaultsIdentify = [AMBValues getDeviceFingerPrint];
    
    // Checks to make sure we have either a short code OR device fingerprint before moving on
    if ([AMBUtilities stringIsEmpty:[AMBValues getMbsyCookieCode]] && [userDefaultsIdentify isEqual:@{}]) {
        return NO;
    }
    
    return YES;
}

@end
