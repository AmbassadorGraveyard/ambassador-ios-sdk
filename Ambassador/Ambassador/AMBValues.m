//
//  AMBValues.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/28/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBValues.h"

@implementation AMBValues

+ (UIImage*)imageFromBundleWithName:(NSString*)name type:(NSString*)type tintable:(BOOL)tintable {
    if (tintable) {
        return [[UIImage imageWithContentsOfFile:[[AMBValues AMBframeworkBundle] pathForResource:name ofType:type]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        return [UIImage imageWithContentsOfFile:[[AMBValues AMBframeworkBundle] pathForResource:name ofType:type]];
    }
    
}

+ (NSBundle*)AMBframeworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Ambassador.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    
    return frameworkBundle;
}

+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid {
    NSString *baseUrl;
    
#if AMBPRODUCTION
    baseUrl = @"https://mbsy.co/universal/landing/?url=ambassador:ios/";
#else
    baseUrl = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios/";
#endif
    
    return [baseUrl stringByAppendingString:[NSString stringWithFormat:@"&universal_id=%@", uid]];
}

+ (NSUserDefaults*)ambUserDefaults {
    NSUserDefaults *ambDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"AMBDEFAULTS"];
    return ambDefaults;
}

#pragma mark - Setter Methods

+ (void)setMbsyCookieWithCode:(NSString*)cookieCode {
    [[AMBValues ambUserDefaults] setValue:cookieCode forKey:@"mbsy_cookie_code"];
}

+ (void)setDeviceFingerPrintWithDictionary:(NSDictionary *)dictionary {
    [[AMBValues ambUserDefaults] setObject:dictionary forKey:@"device_fingerprint"];
}

#pragma mark - Getter Methods

+ (NSString*)getMbsyCookieCode {
    return [[AMBValues ambUserDefaults] valueForKey:@"mbsy_cookie_code"];
}

+ (NSDictionary *)getDeviceFingerPrint {
    return [[AMBValues ambUserDefaults] valueForKey:@"device_fingerprint"];
}

@end
