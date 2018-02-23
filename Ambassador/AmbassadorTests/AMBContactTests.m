//
//  AMBContactTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "AMBContact.h"

@interface AMBFullContact (Test)

- (NSMutableArray*)getPhoneNumbers:(ABRecordRef)recordRef withFirstName:(NSString*)firstName lastName:(NSString*)lastName contactImage:(UIImage*)image;
- (NSMutableArray*)getEmailAddresses:(ABRecordRef)recordRef withFirstName:(NSString*)firstName lastName:(NSString*)lastName contactImage:(UIImage*)image;

@end


@interface AMBContactTests : XCTestCase

@end

@implementation AMBContactTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - AMBContact Tests

- (void)testInit {
    // GIVEN
    ABRecordRef ref = [self createRef];
    
    // WHEN
    AMBFullContact *contact = [[AMBFullContact alloc] initWithABPersonRef:ref];
    
    // THEN
    XCTAssertNotNil(contact);
}

- (void)testFullName {
    // GIVEN
    NSString *mockFullName = @"Test McTesty";
    AMBContact *mockContact = [[AMBContact alloc] init];
    mockContact.firstName = @"Test";
    mockContact.lastName = @"McTesty";
    
    // WHEN
    NSString *expectedFullName = [mockContact fullName];
    
    // THEN
    XCTAssertEqualObjects(mockFullName, expectedFullName, @"%@ is not equal to %@", mockFullName, expectedFullName);
}


#pragma mark - AMBFullContact Tests

- (void)testGetPhoneNumbers {
    // GIVEN
    ABRecordRef ref = [self createRef];
    AMBFullContact *fullContact = [[AMBFullContact alloc] init];
    
    // WHEN
    NSMutableArray *returnArray = [fullContact getPhoneNumbers:ref withFirstName:@"First" lastName:@"Last" contactImage:nil];
    
    // THEN
    XCTAssertNotEqual([returnArray count], 0);
}

- (void)testGetEmailAddresses {
    // GIVEN
    ABRecordRef ref = [self createRef];
    AMBFullContact *fullContact = [[AMBFullContact alloc] init];
    
    // WHEN
    NSMutableArray *returnArray = [fullContact getEmailAddresses:ref withFirstName:@"First" lastName:@"Last" contactImage:nil];
    
    // THEN
    XCTAssertNotEqual([returnArray count], 0);
}


#pragma mark - Helper Functions

- (ABRecordRef)createRef {
    // Create the contact
    ABRecordRef contact = ABPersonCreate();
    
    // Set the first and last names
    ABRecordSetValue(contact, kABPersonFirstNameProperty, (__bridge CFStringRef)@"First", nil);
    ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFStringRef)@"Last", nil);
    
    // Set the phone number
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)@"123456789", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(contact, kABPersonPhoneProperty, phoneNumbers, nil);
    CFRelease(phoneNumbers);
    
    // Set the email address
    ABMutableMultiValueRef emailAddresses = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(emailAddresses, @"first.last@getambassador.com", kABWorkLabel, NULL);
    ABRecordSetValue(contact, kABPersonEmailProperty, emailAddresses, nil);
    CFRelease(emailAddresses);
    
    return contact;
}

@end
