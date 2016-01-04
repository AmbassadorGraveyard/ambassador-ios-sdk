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

- (void)loadWithDelegate:(id)delegate {
    self.delegate = delegate;
    [self setUp];
}

- (void)setUp
{
    DLog();
    //Initialize containers
    self.emailAddresses = [[NSMutableArray alloc] init];
    self.phoneNumbers = [[NSMutableArray alloc] init];
    
    [self getPermissions];
}

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

- (void)getPermissions
{
    DLog();
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        DLog(@"Don't have permission to access contacts");
        [self requestContactsPermission];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        DLog(@"Already had permission to access contacts");
        [self loadContacts];
    }
    else
    {
        [self requestContactsPermission];
    }
}

- (void)requestContactsPermission
{
    DLog(@"Asking for permission to access contacts");
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted)
        {
            DLog(@"Contact access permission request denied");
            [self throwContactLoadError];
        }
        else
        {
            DLog(@"Contact access permission request granted");
            [self loadContacts];
        }
    });
}

- (void)throwContactLoadError
{
    [self.delegate contactsFailedToLoadWithError:@"Couldn't load contacts" message:@"Sharing requires access to your contact book. You can enable this in your settings."];
}



#pragma mark - Main contacts loop
- (void)loadContacts {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (addressBook != nil) {
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        NSArray *contactArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonFirstNameProperty); // Load addressbook
        
        // Main contact loop
        for (NSUInteger i = 0; i < [contactArray count]; ++i) {
            ABRecordRef person = (__bridge ABRecordRef)contactArray[i];
            AMBFullContact *contact = [[AMBFullContact alloc] initWithABPersonRef:person];
            [self.phoneNumbers addObjectsFromArray:contact.phoneContacts];
            [self.emailAddresses addObjectsFromArray:contact.emailContacts];
        }
        
        [self.delegate contactsFinishedLoadingSuccessfully];
    }
}

@end
