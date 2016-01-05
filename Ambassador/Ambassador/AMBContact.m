//
//  Contact.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBContact.h"

@implementation AMBContact

#pragma mark - Helper functions

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end


@implementation AMBFullContact

- (instancetype)initWithABPersonRef:(ABRecordRef)recordRef {
    NSString *firstName = (__bridge NSString*)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    firstName = (![firstName isEqualToString:@"(null)"] && firstName) ? firstName : @"";
    
    NSString *lastName = (__bridge NSString*)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    lastName = (![lastName isEqualToString:@"(null)"] && lastName) ? lastName : @"";
    
    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(recordRef);
    UIImage *contactImage = [UIImage imageWithData:imgData];
    
    self.phoneContacts = [self getPhoneNumbers:recordRef withFirstName:firstName lastName:lastName contactImage:contactImage];
    self.emailContacts = [self getEmailAddresses:recordRef withFirstName:firstName lastName:lastName contactImage:contactImage];
    
    return self;
}

- (NSMutableArray*)getPhoneNumbers:(ABRecordRef)recordRef withFirstName:(NSString*)firstName lastName:(NSString*)lastName contactImage:(UIImage*)image {
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int)ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phoneLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
        NSString *number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        
        AMBContact *phoneContact = [[AMBContact alloc] init];
        phoneContact.firstName = firstName;
        phoneContact.lastName = lastName;
        phoneContact.label = (phoneLabel) ? [phoneLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_.$!<>"]] : @"Other";
        phoneContact.value = number;
        phoneContact.contactImage = image;
        phoneContact.fullContact = self;
        
        [returnArray addObject:phoneContact];
    }
    
    return returnArray;
}

- (NSMutableArray*)getEmailAddresses:(ABRecordRef)recordRef withFirstName:(NSString*)firstName lastName:(NSString*)lastName contactImage:(UIImage*)image  {
    ABMultiValueRef emailAddresses = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int)ABMultiValueGetCount(emailAddresses); i++) {
        NSString *emailLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(emailAddresses, i);
        NSString *address = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailAddresses, i);
        
        AMBContact *emailContact = [[AMBContact alloc] init];
        emailContact.firstName = firstName;
        emailContact.lastName = lastName;
        emailContact.label = (emailLabel) ? [emailLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_.$!<>"]] : @"Other";
        emailContact.value = address;
        emailContact.contactImage = image;
        emailContact.fullContact = self;
        
        [returnArray addObject:emailContact];
    }
    
    return returnArray;
}

@end
