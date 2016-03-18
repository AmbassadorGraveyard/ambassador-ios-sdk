//
//  Validator.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/17/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validator : NSObject

+ (BOOL)isValidEmail:(NSString*)emailAddress;
+ (BOOL)emptyString:(NSString*)string;

@end
