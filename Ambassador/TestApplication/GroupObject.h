//
//  GroupObject.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupObject : NSObject

@property (nonatomic, strong) NSString * groupID;
@property (nonatomic, strong) NSString * groupName;
@property (nonatomic, strong) NSString * UID;

- (instancetype)initWithName:(NSString *)name ID:(NSString *)ID UID:(NSString *)UID;

@end
