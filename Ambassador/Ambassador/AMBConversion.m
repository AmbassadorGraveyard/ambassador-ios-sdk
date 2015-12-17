//
//  Conversion.m
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBConversion.h"
#import "AMBConstants.h"
#import "AMBCoreDataManager.h"
#import "AMBConversionParametersEntity.h"


#pragma mark - Local Constants

#if AMBPRODUCTION
NSString * const AMB_CONVERSION_URL = @"https://api.getambassador.com/universal/action/conversion/";
#else
NSString * const AMB_CONVERSION_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/";
#endif


@implementation AMBConversion


#pragma mark - API Functions

- (void)registerConversionWithParameters:(AMBConversionParameters *)parameters completion:(void (^)(NSError *error))completion {
    NSLog(@"[Ambassador] Attempting to save conversion -\n%@", [parameters description]);
    NSError *error = [parameters checkForError];
    
    if (!error) { [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]]; }
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

- (void)sendConversions {
    DLog(@"Checking for Conversions to send");
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
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self payloadForConversionCallWithFP:userDefaultsIdentify mbsyFields:fieldsDictionary] options:0 error:nil];
            
            //Create the POST request
            NSURL *url = [NSURL URLWithString:AMB_CONVERSION_URL];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[AMBValues getUniversalToken] forHTTPHeaderField:@"Authorization"];
            request.HTTPBody = jsonData;

            
            
            #if AMBPRODUCTION
                NSURLSession *urlSession = [NSURLSession sharedSession];
            #else
                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
            #endif
            
            NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                DLog(@"CONVERSION CALL - Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                if (!error) {
                    if ([AMBUtilities isSuccessfulStatusCode:((NSHTTPURLResponse *)response).statusCode]) {
                        DLog(@"Response from backend for CONVERSION CALL = %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                        [AMBCoreDataManager deleteCoreDataObject:entity];
                    } else {
                        NSLog(@"[Ambassador] Error - Server reponse from sending conversion:%ld - %@", (long)((NSHTTPURLResponse *)response).statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                    }
                    
                    return;
                }
                
                DLog(@"CONVERSION CALL Error: %@", error.localizedDescription);
            }];
            
            [task resume];
        }
    }
}


#pragma mark - NSURL Delegete

// Allows certain requests to be made for dev servers when running in unit tests for Circle
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if([challenge.protectionSpace.host isEqualToString:@"dev-ambassador-api.herokuapp.com"]) { // Makes sure that it's our url being challenged
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
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
