//
//  ServiceSelectorPreferences.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ServiceSelectorPreferences.h"

@implementation ServiceSelectorPreferences

- (id)init
{
    if ([super init])
    {
        self.titleLabelText = @"Spread the word";
        self.navBarTitle = @"Refer your friends";
        self.descriptionLabelText = @"Refer a friend to get rewards";
        self.defaultShareMessage = @"I'm a fan of this company, check them out!";
    }
    
    return self;
}

@end
