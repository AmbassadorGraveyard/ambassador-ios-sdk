//
//  AMBErrors.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBErrors.h"

@implementation AMBErrors


#pragma mark - Error Logs

+ (void)conversionError:(NSInteger)statusCode errorData:(NSData*)data {
    NSLog(@"[Ambassador] Error Sending Conversion - Status Code=%li Failure Reason=%@", (long)statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
}

+ (void)errorNoMatchingCampaignIdError:(NSString*)campaignId {
    NSLog(@"[Ambassador] Error loading RAF - There were no Campaign IDs found matching '%@'.  Please make sure that the correct Campaign ID is being passed when presenting a RAF widget", campaignId);
}


#pragma mark - NSErrors

+ (NSError*)restrictedConversionError {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Conversion was not registered", nil),
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The conversion is restricted to install", nil),
                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Change the Conversion's 'restrictToInstall' boolean to NO/false", nil) };
    
    return [NSError errorWithDomain:@"AmbassadorErrorDomain" code:0 userInfo:userInfo];
}


#pragma mark - AlertView Errors

@end
