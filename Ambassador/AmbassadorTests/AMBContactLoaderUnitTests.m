//
//  AMBContactLoaderUnitTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/5/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBContactLoader.h"

@interface AMBContactLoader (Test)

- (void)loadContacts;
- (void)emptyOutArrays;

@end


@interface AMBContactLoaderUnitTests : XCTestCase <AMBContactLoaderDelegate>

@property (nonatomic, strong) AMBContactLoader * loader;
@property (nonatomic) id mockLoader;

@end

@implementation AMBContactLoaderUnitTests

- (void)setUp {
    [super setUp];
    if (!self.loader) {
        self.loader = [AMBContactLoader sharedInstance];
    }
    
    self.mockLoader = [OCMockObject partialMockForObject:self.loader];
}

- (void)tearDown {
    [self.mockLoader stopMocking];
    [super tearDown];
}

- (void)testSharedInstance {
    XCTAssertNotNil(self.loader);
}

- (void)testAttemptLoadWithoutCache {
    // GIVEN
    __block BOOL expectedCache;
    
    // WHEN
    [self.loader attemptLoadWithDelegate:nil loadingFromCache:^(BOOL isCached) {
        expectedCache = isCached;
    }];
    
    // THEN
    XCTAssertFalse(expectedCache);
}

- (void)testLoadContactsWithCache {
    // GIVEN
    self.loader.phoneNumbers = [NSMutableArray arrayWithObject:@"555-555-5555"];
    self.loader.emailAddresses = [NSMutableArray arrayWithObject:@"fakeemail@example.com"];
    self.loader.delegate = self;
    
    id mockDelegate = [OCMockObject partialMockForObject:self.loader.delegate];
    [[[mockDelegate expect] andDo:nil] contactsFinishedLoadingSuccessfully];
    
    // WHEN
    [self.loader loadContacts];
    
    // THEN
    [mockDelegate verify];
    [self.loader emptyOutArrays];
}

- (void)testLoadContactsWithoutCache {
    // GIVEN
    [[[self.mockLoader expect] andDo:nil] emptyOutArrays];
    
    self.loader.delegate = self;
    id mockDelegate = [OCMockObject partialMockForObject:self.loader.delegate];
    [[[mockDelegate expect] andDo:nil] contactsFinishedLoadingSuccessfully];
    
    // WHEN
    [self.loader loadContacts];
    
    // THEN
    [self.mockLoader verify];
    [mockDelegate verify];
}

- (void)testForceReload {
    // GIVEN
    [[[self.mockLoader expect] andDo:nil] emptyOutArrays];
    [[[self.mockLoader expect] andDo:nil] loadContacts];
    
    // WHEN
    [self.loader forceReloadContacts];
    
    // THEN
    [self.mockLoader verify];
}

@end
