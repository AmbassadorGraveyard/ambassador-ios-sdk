//
//  AMBCoreDataManagerTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/4/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBCoreDataManager.h"
#import "AMBCoreDataDelegate.h"

@interface AMBCoreDataManagerTests : XCTestCase

@property (nonatomic) id mockDelegate;

@end

@implementation AMBCoreDataManagerTests

- (void)setUp {
    [super setUp];
    self.mockDelegate = [OCMockObject partialMockForObject:[AMBCoreDataDelegate sharedInstance]];
}

- (void)tearDown {
    [self.mockDelegate stopMocking];
    [super tearDown];
}

- (void)testSaveNewObject {
    // GIVEN
    NSString *testEntityName = @"TestEntity";
    
    id mockContext = [OCMockObject mockForClass:[NSManagedObjectContext class]];
    [[[self.mockDelegate expect] andDo:nil] saveContext];
    [[[self.mockDelegate expect] andReturn:mockContext] managedObjectContext];
    
    id entityMock = [OCMockObject mockForClass:[NSEntityDescription class]];
    [[[entityMock expect] andReturn:entityMock] entityForName:testEntityName inManagedObjectContext:mockContext];
    
    id mockManagedObject = [OCMockObject mockForClass:[NSManagedObject class]];
    [[[mockManagedObject expect] andReturn:mockManagedObject] alloc];
    (void)[[[mockManagedObject expect] andReturn:mockManagedObject] initWithEntity:entityMock insertIntoManagedObjectContext:mockContext];
    
    // WHEN
    [AMBCoreDataManager saveNewObjectToCoreDataWithEntityName:testEntityName valuesToSave:@{}];
    
    // THEN
    [mockContext verify];
    [mockManagedObject verify];
    [self.mockDelegate verify];
}

- (void)testGetAllEntities {
    // GIVEN
    NSString *testEntityName = @"TestEntity";
    NSError *error;
    id mockContext = [OCMockObject mockForClass:[NSManagedObjectContext class]];
    [[[mockContext expect] andDo:nil] executeFetchRequest:[OCMArg any] error:[OCMArg setTo:error]];
    [[[self.mockDelegate expect] andReturn:mockContext] managedObjectContext];
    
    // WHEN
    [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:testEntityName alphabetizeByProperty:nil];
    
    // THEN
    [mockContext verify];
}

- (void)testGetAllEntitiesNoProperty {
    // GIVEN
    NSString *entityName = @"TestEntity";
    
    id mockCoreDataMgr = [OCMockObject mockForClass:[AMBCoreDataManager class]];
    [[[mockCoreDataMgr expect] andDo:nil] getAllEntitiesFromCoreDataWithEntityName:entityName alphabetizeByProperty:nil];
    
    // WHEN
    [AMBCoreDataManager getAllEntitiesFromCoreDataWithEntityName:entityName];
    
    // THEN
    [mockCoreDataMgr verify];
}

- (void)testDeleteCoreData {
    // GIVEN
    id fakeObject = [OCMockObject mockForClass:[NSManagedObject class]];
    NSError *error;
    
    id mockContext = [OCMockObject mockForClass:[NSManagedObjectContext class]];
    [[[self.mockDelegate expect] andReturn:mockContext] managedObjectContext];
    [[[mockContext expect] andDo:nil] deleteObject:fakeObject];
    [[[mockContext expect] andDo:nil] save:[OCMArg setTo:error]];
    
    // WHEN
    [AMBCoreDataManager deleteCoreDataObject:fakeObject];
    
    // THEN
    [mockContext verify];
}

@end
