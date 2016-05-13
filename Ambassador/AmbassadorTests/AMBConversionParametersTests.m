//
//  AMBConversionParametersTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBConversionParameters.h"
#import "AMBConversionParameter_Internal.h"

@interface AMBConversionParametersTests : XCTestCase

@end

@implementation AMBConversionParametersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Initialization Tests

- (void)testInitWithEntity {
    // GIVEN
    id mockEntity = [OCMockObject mockForClass:[AMBConversionParametersEntity class]];
    [[[mockEntity expect] andReturn:@1] mbsy_campaign];
    [[[mockEntity expect] andReturn:@""] mbsy_email];
    [[[mockEntity expect] andReturn:@""] mbsy_add_to_group_id];
    [[[mockEntity expect] andReturn:@""] mbsy_custom1];
    [[[mockEntity expect] andReturn:@""] mbsy_custom2];
    [[[mockEntity expect] andReturn:@""] mbsy_custom3];
    [[[mockEntity expect] andReturn:@""] mbsy_event_data1];
    [[[mockEntity expect] andReturn:@""] mbsy_event_data2];
    [[[mockEntity expect] andReturn:@""] mbsy_event_data3];
    [[[mockEntity expect] andReturn:@""] mbsy_first_name];
    [[[mockEntity expect] andReturn:@""] mbsy_last_name];
    [[[mockEntity expect] andReturn:@""] mbsy_transaction_uid];
    [[[mockEntity expect] andReturn:@""] mbsy_uid];
    [[[mockEntity expect] andReturn:@YES] mbsy_auto_create];
    [[[mockEntity expect] andReturn:@YES] mbsy_deactivate_new_ambassador];
    [[[mockEntity expect] andReturn:@1] mbsy_email_new_ambassador];
    [[[mockEntity expect] andReturn:@1] mbsy_is_approved];
    [[[mockEntity expect] andReturn:@1] mbsy_revenue];
    
    AMBConversionParameters *parameters = [[AMBConversionParameters alloc] initWithEntity:mockEntity];
    
    // WHEN
    NSError *checkError = [parameters checkForError];
    
    // THEN
    [mockEntity verify];
    XCTAssertNotNil(checkError);
}

- (void)testInitWithProperties {
    // GIVEN
    NSNumber *campaign = @200;
    NSNumber *revenue = @1.00;
    NSNumber *commissionApproved = @NO;
    NSString *eventData1 = @"testData";
    NSString *blankString = @"";
    
    NSDictionary *properties = @{ @"campaign" : campaign,
                                  @"revenue" : revenue,
                                  @"commissionApproved" : commissionApproved,
                                  @"eventData1" : eventData1 };
    
    
    
    // WHEN
    AMBConversionParameters *params = [[AMBConversionParameters alloc] initWithProperties:properties];
    
    // THEN
    XCTAssertEqualObjects(params.mbsy_campaign, campaign);
    XCTAssertEqualObjects(params.mbsy_revenue, revenue);
    XCTAssertEqualObjects(params.mbsy_is_approved, commissionApproved);
    XCTAssertEqualObjects(params.mbsy_event_data1, eventData1);
    XCTAssertEqualObjects(params.mbsy_event_data2, blankString);
    XCTAssertEqualObjects(params.mbsy_event_data3, blankString);
    XCTAssertEqualObjects(params.mbsy_transaction_uid, blankString);
}

- (void)testCheckForNoError {
    // GIVEN
    AMBConversionParameters *mockParamsWithoutError = [[AMBConversionParameters alloc] init];
    mockParamsWithoutError.mbsy_email = @"test@test.com";
    mockParamsWithoutError.mbsy_campaign = @100;
    mockParamsWithoutError.mbsy_revenue = @100;
    
    // WHEN
    NSError *expectedError = [mockParamsWithoutError checkForError];
    
    // THEN
    XCTAssertNil(expectedError);
}

- (void)testCheckForError {
    // GIVEN
    AMBConversionParameters *mockParamsWithError = [[AMBConversionParameters alloc] init];
    mockParamsWithError.mbsy_email = @"test@test.com";
    mockParamsWithError.mbsy_campaign = @100;
    
    // WHEN
    NSError *expectedError = [mockParamsWithError checkForError];
    
    // THEN
    XCTAssertNotNil(expectedError);
}

- (void)testPropertyDictionary {
    // GIVEN
    AMBConversionParameters *mockParams = [[AMBConversionParameters alloc] init];
    mockParams.mbsy_campaign = @200;
    mockParams.mbsy_revenue = @100;
    mockParams.mbsy_email = @"test@test.com";
    
    // WHEN
    NSDictionary *propertyDict = [mockParams propertyDictionary];
    
    // THEN
    XCTAssertTrue([propertyDict count] > 0);
    XCTAssertEqualObjects(mockParams.mbsy_campaign, propertyDict[@"mbsy_campaign"]);
    XCTAssertEqualObjects(mockParams.mbsy_revenue, propertyDict[@"mbsy_revenue"]);
    XCTAssertEqualObjects(mockParams.mbsy_email, propertyDict[@"mbsy_email"]);
}

- (void)testIsStringProperty {
    // GIVEN
    NSArray *mockStringArray = @[@"mbsy_email", @"mbsy_first_name", @"mbsy_last_name", @"mbsy_uid", @"mbsy_custom1", @"mbsy_custom2", @"mbsy_custom3", @"mbsy_transaction_uid", @"mbsy_add_to_group_id", @"mbsy_event_data1", @"mbsy_event_data2", @"mbsy_event_data3"];
    
    // WHEN/THEN
    for (NSString *string in mockStringArray) {
        BOOL isString = [AMBConversionParameters isStringProperty:string];
        XCTAssertTrue(isString);
    }
}

@end
