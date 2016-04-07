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
    
    // If the version number has extra characters appended for the App Store, it removes them when showing SDK version
    if ([majorVersion length] > 5) { majorVersion = [majorVersion substringToIndex:5]; }
    
    return majorVersion;
}

@end
