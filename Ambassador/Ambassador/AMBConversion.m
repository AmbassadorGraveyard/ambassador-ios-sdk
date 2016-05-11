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

- (void)registerConversionWithParameters:(AMBConversionParameters *)parameters completion:(void (^)(NSError *error))completion {
    NSError *error = [parameters checkForError];
    
    if (!error) { [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]]; }
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

- (void)retryUnsentConversions {
    // If no device fingerprint is available, an empty dictionary will be returned
    NSDictionary *userDefaultsIdentify = [AMBValues getDeviceFingerPrint];

    // Checks to make sure we have either a short code OR device fingerprint before moving on
    if ([[AMBValues getMbsyCookieCode] isEqualToString:@""] && [userDefaultsIdentify isEqual:@{}]) {
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
            [self sendConversion:parameters identifyInfo:userDefaultsIdentify success:^{
                DLog(@"Conversion retry success - %@", parameters);
                
                // Deletes the coredata object after successful send
                [AMBCoreDataManager deleteCoreDataObject:entity];
            } failure:^{
                DLog(@"Conversion retry failed - %@", parameters);
            }];
        }
    } 
}

- (void)sendConversion:(AMBConversionParameters *)parameters identifyInfo:(NSDictionary *)identifyInfo success:(void(^)())success failure:(void(^)())failure {
    // Creates a mutable dictionary rom the parameter object's property dictionary
    NSMutableDictionary *fieldsDictionary = [[parameters propertyDictionary] mutableCopy];
    [fieldsDictionary setValue:[AMBValues getMbsyCookieCode] forKey:@"mbsy_short_code"];
    
    // Creates the payload to send in the POST body
    NSDictionary *payloadDict = [self payloadForConversionCallWithFP:identifyInfo mbsyFields:fieldsDictionary];
    
    // Make network call to send off our conversion
    [[AMBNetworkManager sharedInstance] sendRegisteredConversion:payloadDict success:^(NSDictionary *response) {
        DLog(@"Conversion Send Response - %@", response);
        
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

@end
