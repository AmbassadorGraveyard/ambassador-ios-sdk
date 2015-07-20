//
//  Contact.h
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property NSString *firstName;
@property NSString *lastName;
@property NSString *label;
@property NSString *value;

- (NSString *)fullName;

@end
