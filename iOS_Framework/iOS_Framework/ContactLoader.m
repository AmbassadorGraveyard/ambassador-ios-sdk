//
//  ContactLoader.m
//  iOS_Framework
//
//  Created by Diplomat on 7/8/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ContactLoader.h"
#import <AddressBook/AddressBook.h>
#import "Constants.h"
#import "Contact.h"
#import "Utilities.h"



@interface ContactLoader ()

@property ABAddressBookRef addressBook;
@property NSArray *allContacts;

@end



@implementation ContactLoader


#pragma mark - Initialization
- (id)initWithDelegate:(id<ContactLoaderDelegate>)delegate
{
    if ([super init])
    {
        DLog();
        self.delegate = delegate;
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    DLog();
    //Initialize containers
    self.emailAddresses = [[NSMutableArray alloc] init];
    self.phoneNumbers = [[NSMutableArray alloc] init];
    
    //Set up address book
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    [self getPermissions];
}

- (void)getPermissions
{
    DLog();
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        DLog(@"Don't have permission to access contacts");
        [self.delegate contactsFailedToLoadWithError:@"Couldn't load contacts" message:@"Sharing requires access to your contacts. You can enable this in your settings."];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        DLog(@"Already had permission to access contacts");
        [self loadContacts];
    }
    else
    {
        DLog(@"Asking for permission to access contacts");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted)
            {
                DLog(@"Contact access permission request denied");
                [self.delegate contactsFailedToLoadWithError:@"Couln't load contacts" message:@"Sharing requires access to your contact books. You can enable this in your settings"];
            }
            DLog(@"Contact access permission request granted");
            [self loadContacts];
        });
    }
}



#pragma mark - Main contacts loop
- (void)loadContacts
{
    DLog();
    if (self.addressBook != nil)
    {
        ABRecordRef source = ABAddressBookCopyDefaultSource(self.addressBook);
        
        // Load addressbook
        self.allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(self.addressBook, source, kABPersonFirstNameProperty);
        
        // Main contact loop
        for (NSUInteger i = 0; i < self.allContacts.count; ++i)
        {
            ABRecordRef person = (__bridge ABRecordRef)self.allContacts[i];
            [self getEmailsForPerson:person];
            [self getNumbersForPerson:person];
        }
    }
}



#pragma mark - Accessory Functions
- (void)getNumbersForPerson:(ABRecordRef)person
{
    // Get name
    NSDictionary *name = [self getNameForPerson:person];
    
    // Emails for contact
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    // Cycle through emails
    for (CFIndex j = 0; j < ABMultiValueGetCount(emails); ++j) {
        
        //String to store label of each email type
        NSString *emailLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(emails, j);
        
        //Strip the charaters surrounding label type
        emailLabel = [emailLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_.$!<>"]];
        
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, j);
        
        Contact *contact = [[Contact alloc] init];
        contact.firstName = name[@"firstName"];
        contact.lastName = name[@"lastName"];
        contact.label = emailLabel;
        contact.value = email;
        
        [self.emailAddresses addObject:contact];
    }
}

- (void)getEmailsForPerson:(ABRecordRef)person
{
    // Get name
    NSDictionary *name = [self getNameForPerson:person];
    
    // Phone numbers for contact
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    NSString *phoneLabel;
    
    // Cycle through phone numbers
    for (CFIndex j = 0; j < ABMultiValueGetCount(phones); ++j)
    {
        //String to store lable of each number type
        phoneLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, j);
        
        //Check if it's mobile of iPhone
        if ([phoneLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel] ||
            [phoneLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel] ||
            YES ) //TODO: remove YES
        {
            //Strip the charaters surrounding label type
            phoneLabel = [phoneLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_.$!<>"]];
            
            //Get the number
            NSString *number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, j);
            
            //Remove non-numeric characters from number string
            NSCharacterSet *breakAtCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            number = [[number componentsSeparatedByCharactersInSet:breakAtCharacters] componentsJoinedByString:@""];
            
            Contact *contact = [[Contact alloc] init];
            contact.firstName = name[@"firstName"];
            contact.lastName = name[@"lastName"];
            contact.label = phoneLabel;
            contact.value = [self formatPhoneNumber:number];
            
            [self.phoneNumbers addObject:contact];
        }
    }
}

- (NSDictionary *)getNameForPerson:(ABRecordRef)person
{
    NSString *firstName, *lastName;
    firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    return @{
             @"firstName" : firstName,
             @"lastName" : lastName
             };
}

- (NSString *)formatPhoneNumber:(NSString *)number
{
    NSMutableString *returnNumber = [NSMutableString stringWithString:number];
    if (number.length == 11)
    {
        //country code
        [returnNumber insertString:@" " atIndex:1];
        [returnNumber insertString:@"(" atIndex:2];
        [returnNumber insertString:@")" atIndex:6];
        [returnNumber insertString:@" " atIndex:7];
        [returnNumber insertString:@"-" atIndex:11];
    }
    else if (number.length == 10)
    {
        // area code
        [returnNumber insertString:@"(" atIndex:0];
        [returnNumber insertString:@")" atIndex:4];
        [returnNumber insertString:@" " atIndex:5];
        [returnNumber insertString:@"-" atIndex:9];
    }
    else
    {
        // simple number
        [returnNumber insertString:@"-" atIndex:3];
    }
    return returnNumber;
}

@end
