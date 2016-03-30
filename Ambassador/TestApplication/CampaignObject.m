//
//  CampaignObject.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "CampaignObject.h"

@implementation CampaignObject

// Decodes properties that were previously recorded
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.campID = [decoder decodeObjectForKey:@"campID"];
    }
    
    return self;
}

// Encodes Campaigns in order to store to user defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.campID forKey:@"campID"];
}


@end
