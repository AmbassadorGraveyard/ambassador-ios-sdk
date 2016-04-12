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

- (void)sendConversions {
    NSDictionary *userDefaultsIdentify = [AMBValues getDeviceFingerPrint]; // If no device fingerprint is available, an empty dictionary will be returned

    // Checks to make sure we have either a short code OR device fingerprint before moving on
    if ([[AMBValues getMbsyCookieCode] isEqualToString:@""] && [userDefaultsIdentify isEqual:@{}]) {
        return;
    }
    
    NSArray *storedConversionArray = [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:@"AMBConversionParametersEntity"];
    
    if ([storedConversionArray count] > 0) {
        for (AMBConversionParametersEntity *entity in storedConversionArray) {
            AMBConversionParameters *parameters = [[AMBConversionParameters alloc] initWithEntity:entity];
            NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionaryWithDictionary:[parameters propertyDictionary]];
            [fieldsDictionary setValue:[AMBValues getMbsyCookieCode] forKey:@"mbsy_short_code"];
            
            [[AMBNetworkManager sharedInstance] sendRegisteredConversion:[self payloadForConversionCallWithFP:userDefaultsIdentify mbsyFields:fieldsDictionary] success:^(NSDictionary *response) {
                [AMBCoreDataManager deleteCoreDataObject:entity];
            } failure:^(NSInteger statusCode, NSData *data) {
                [AMBErrors errorLogCannotSendConversion:statusCode errorData:data];
            }];
        }
    } 
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
