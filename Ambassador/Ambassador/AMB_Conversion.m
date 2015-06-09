//
//  AMB_Conversion.m
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBASSADORConstants.h"
#import "AMB_Conversion.h"

@implementation AMB_Conversion

#pragma mark - Inits
//TODO: This may need to be implemented depending on final logic used

#pragma mark - API Functions
- (BOOL)registerConversion
{
    return [self registerConversionWithEmail:noConversionEmailDefualtString];
}

- (BOOL)registerConversionWithEmail:(NSString *)email
{
    if ([email isEqualToString:noConversionEmailDefualtString])
    {
        //TODO: Handle situation when email is not passed
        [self makeAPICallWithEmail:email];
    }
    else
    {
        //TODO: Handle situation when email is passed
        [self makeAPICallWithEmail:email];
    }
    return YES;
}


#pragma mark - Helper Functions
- (void)makeAPICallWithEmail:(NSString*)email
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@""]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200)
        {
            //TODO: Do something with successful call
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *identifyData = [userDefaults objectForKey:NSUserDefaultsKeyName];
            NSLog(@"%@", identifyData);
        }
        else
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Non 200 server response"};
            //TODO: Fix the code in the error
            NSLog(@"%@", [NSError errorWithDomain:conversionErrorDomain
                                             code:httpResponse.statusCode
                                         userInfo:userInfo]);
        }
        
    }] resume];
}

@end
