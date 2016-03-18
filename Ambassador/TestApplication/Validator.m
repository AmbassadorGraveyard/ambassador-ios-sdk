//
//  Validator.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/17/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "Validator.h"

@implementation Validator

+ (BOOL)isValidEmail:(NSString*)emailAddress {
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    
    return [emailTest evaluateWithObject:emailAddress];
}

+ (BOOL)emptyString:(NSString*)string {
    // Gets string value without any spaces
    NSString *stringWithNoSpaces = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([stringWithNoSpaces isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

@end
