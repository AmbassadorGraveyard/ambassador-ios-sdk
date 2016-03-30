//
//  ValuesHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/23/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ValuesHandler.h"

@implementation ValuesHandler

+ (NSString*)getVersionNumber {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return majorVersion;
}

@end
