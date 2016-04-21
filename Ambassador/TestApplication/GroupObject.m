//
//  GroupObject.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "GroupObject.h"

@implementation GroupObject

// Decodes properties that were previously recorded
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.groupName = [decoder decodeObjectForKey:@"groupName"];
        self.groupID = [decoder decodeObjectForKey:@"groupID"];
        self.UID = [decoder decodeObjectForKey:@"UID"];
    }
    
    return self;
}

// Encodes Campaigns in order to store to user defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.groupName forKey:@"groupName"];
    [encoder encodeObject:self.groupID forKey:@"groupID"];
    [encoder encodeObject:self.UID forKey:@"UID"];
}

- (instancetype)initWithName:(NSString *)name ID:(NSString *)ID UID:(NSString *)UID {
    self = [super init];
    self.groupName = name;
    self.groupID = ID;
    self.UID = UID;
    
    return self;
}

@end
