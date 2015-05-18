//
//  AMBBase.m
//  ObjC
//
//  Created by Diplomat on 5/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBBase.h"

@interface AMBBase ()

@end

@implementation AMBBase

- (id)initWithKeyString:(NSString*)keyString {
    self = [super init];
    
    if (self) {
        self.keyString = keyString;
    }
    
    return self;
}

- (id)init {
    return [self initWithKeyString:@"7g1a8dumog40o61y5irl1sscm4nu6g60"];
}

@end
