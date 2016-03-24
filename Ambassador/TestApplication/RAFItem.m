//
//  RAFItem.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFItem.h"

@implementation RAFItem

// Decodes properties that were previously recorded
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.rafName = [decoder decodeObjectForKey:@"rafName"];
        self.plistFullName = [decoder decodeObjectForKey:@"plistFullName"];
        self.dateCreated = [decoder decodeObjectForKey:@"dateCreated"];
    }
    
    return self;
}

// Encodes RAFItem in order to store to user defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.rafName forKey:@"rafName"];
    [encoder encodeObject:self.plistFullName forKey:@"plistFullName"];
    [encoder encodeObject:self.dateCreated forKey:@"dateCreated"];
}

- (instancetype)initWithName:(NSString*)name plistDict:(NSMutableDictionary*)dict {
    self = [super init];
    self.rafName = name;
    self.plistFullName = [NSString stringWithFormat:@"AMBTESTAPP%@", name];
    self.dateCreated = [NSDate date];
    self.plistDict = dict;
    
    return self;
}

@end
