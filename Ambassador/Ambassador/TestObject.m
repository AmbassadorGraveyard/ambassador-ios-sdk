//
//  TestObject.m
//  Ambassador
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "TestObject.h"
#import "secretObject.h"

@implementation TestObject
- (NSString *)sayHello {
    NSString *str = @"Hello world";
    NSLog(@"%@", str);
    return str;
}

+ (NSBundle *)frameworkBundle; {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Ambassador.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    [[secretObject alloc] init];
    return frameworkBundle;
}
@end
