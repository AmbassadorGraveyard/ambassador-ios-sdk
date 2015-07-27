//
//  RAFParameters.m
//  iOS_Framework
//
//  Created by Jake Dunahee on 7/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "RAFParameters.h"

@implementation RAFParameters

- (id)init
{
    if ([super init])
    {
        self.navBarTitle = @"Refer your friends";
        self.welcomeTitle = @"Spread the word";
        self.welcomeDescription = @"Refer a friend to get rewards";
        self.defaultShareMessage = @"I'm a fan of this company, check them out!";
    }

    return self;
}

@end
