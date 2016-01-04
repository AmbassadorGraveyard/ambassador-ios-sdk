//
//  ContactLoader.m
//  iOS_Framework
//
//  Created by Diplomat on 7/8/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBContactLoader.h"
#import <AddressBook/AddressBook.h>
#import "AMBContact.h"
#import "AMBUtilities.h"


@implementation AMBContactLoader


#pragma mark - LifeCycle

+ (AMBContactLoader*)sharedInstance {
    static AMBContactLoader *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AMBContactLoader alloc] init];
        _sharedInstance.emailAddresses = [[NSMutableArray alloc] init];
        _sharedInstance.phoneNumbers = [[NSMutableArray alloc] init];
        [_sharedInstance loadContacts];
    });
    
    return _sharedInstance;
}


#pragma mark - Loading Functionality 

- (void)attemptLoadWithDelegate:(id)delegate {
    self.delegate = delegate;
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            DLog(@"CONTACT LOADER - Already had permission to access contacts");
            [self loadContacts];
            break;
        case kABAuthorizationStatusDenied || kABAuthorizationStatusRestricted:
            DLog(@"CONTACT LOADER - Have been denied permission to access contacts");
            [self throwContactLoadError];
        default:
            DLog(@"CONTACT LOADER - Need to ask for permission");
            [self requestContactsPermission];
            break;
    }
}

- (void)loadContacts {
    // Checks if our phone numbers and emails have aready been loaded and re-uses them
    if ([self.phoneNumbers count] > 0 && [self.emailAddresses count] > 0) {
        [self.delegate contactsFinishedLoadingSuccessfully];
        return;
    }
    
    // If the phoneNumber OR email array are empty, we need to load contacts from the address book
    if (self.phoneNumbers != nil) { [self.phoneNumbers removeAllObjects]; } // Removes all objects if the array have already been initialized
    if (self.emailAddresses != nil) { [self.emailAddresses removeAllObjects]; } // ^^
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (addressBook != nil) {
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        NSArray *contactArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonFirstNameProperty); // Load addressbook
        
        // Loops through all the contacts in contact book
        for (NSUInteger i = 0; i < [contactArray count]; ++i) {
            ABRecordRef person = (__bridge ABRecordRef)contactArray[i];
            AMBFullContact *contact = [[AMBFullContact alloc] initWithABPersonRef:person]; // Creates a contact with all phone numbers and emails that may be included with contact
            [self.phoneNumbers addObjectsFromArray:contact.phoneContacts]; // For every phone number a contact may have, a new contact is made so that all numbers can be selectable
            [self.emailAddresses addObjectsFromArray:contact.emailContacts]; // ^^
        }
        
        [self.delegate contactsFinishedLoadingSuccessfully];
    }
}


#pragma mark - Permissions

- (void)requestContactsPermission {
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, NULL), ^(bool granted, CFErrorRef error) {
        if (!granted) {
            DLog(@"Contact access permission request denied");
            [self throwContactLoadError];
        } else {
            DLog(@"Contact access permission request granted");
            [self loadContacts];
        }
    });
}

- (void)throwContactLoadError {
    [self.delegate contactsFailedToLoadWithError:@"Couldn't load contacts" message:@"Sharing requires access to your contact book. You can enable this in your settings."];
}


@end
