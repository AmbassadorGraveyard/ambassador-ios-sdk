//
//  Contact.h
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

// AMBCONTACT
@interface AMBContact : NSObject

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * value;
@property (nonatomic, strong) UIImage * contactImage;

- (NSString *)fullName;

@end


// AMBFULLCONTACT
@interface AMBFullContact : NSObject

@property (nonatomic, strong) NSArray * phoneContacts;
@property (nonatomic, strong) NSArray * emailContacts;

- (instancetype)initWithABPersonRef:(ABRecordRef)recordRef;

@end
