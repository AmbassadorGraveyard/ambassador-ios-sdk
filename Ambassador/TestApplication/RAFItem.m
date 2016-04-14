//
//  RAFItem.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFItem.h"
#import "AMBValues.h"

@implementation RAFItem

// Decodes properties that were previously recorded
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.rafName = [decoder decodeObjectForKey:@"rafName"];
        self.plistFullName = [decoder decodeObjectForKey:@"plistFullName"];
        self.dateCreated = [decoder decodeObjectForKey:@"dateCreated"];
        self.plistDict = [decoder decodeObjectForKey:@"plistDict"];
        self.campaign = [decoder decodeObjectForKey:@"campaign"];
        self.imageFilePath = [decoder decodeObjectForKey:@"imageFilePath"];
        self.xmlFileData = [decoder decodeObjectForKey:@"xmlFileData"];
    }
    
    return self;
}

// Encodes RAFItem in order to store to user defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.rafName forKey:@"rafName"];
    [encoder encodeObject:self.plistFullName forKey:@"plistFullName"];
    [encoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [encoder encodeObject:self.plistDict forKey:@"plistDict"];
    [encoder encodeObject:self.campaign forKey:@"campaign"];
    [encoder encodeObject:self.imageFilePath forKey:@"imageFilePath"];
    [encoder encodeObject:self.xmlFileData forKey:@"xmlFileData"];
}

- (instancetype)initWithName:(NSString*)name plistDict:(NSMutableDictionary*)dict xmlFileData:(NSData *)xmlData {
    self = [super init];
    self.rafName = name;
    self.plistFullName = [NSString stringWithFormat:@"%@%@", TEST_APP_CONTSTANT, name];
    self.dateCreated = [NSDate date];
    self.plistDict = dict;
    self.xmlFileData = xmlData;
    
    return self;
}

@end
