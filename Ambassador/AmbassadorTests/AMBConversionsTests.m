//
//  AMBConversionsTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 11/11/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBConversion.h"
#import "AMBConversionParameters.h"
#import "AMBConversionParameter_Internal.h"
#import "AMBCoreDataManager.h"
#import "AMBValues.h"
#import "AMBNetworkManager.h"

@interface AMBConversion (Test)

- (NSDictionary*)payloadForConversionCallWithFP:(NSDictionary*)deviceFingerprint mbsyFields:(NSMutableDictionary*)mbsyFields;

@end


@interface AMBConversionsTests : XCTestCase

@property (nonatomic, strong) AMBConversion * conversion;
@property (nonatomic) id mockConversion;

@end

@implementation AMBConversionsTests

- (void)setUp {
    [super setUp];
    if (!self.conversion) {
        self.conversion = [[AMBConversion alloc] init];
    }
    
    self.mockConversion = [OCMockObject partialMockForObject:self.conversion];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [self.mockConversion stopMocking];
    [super tearDown];
}

- (void)testRegisterConversion {
    // GIVEN
    AMBConversionParameters *parameters = [[AMBConversionParameters alloc] init];
    parameters.mbsy_campaign = @123456;
    parameters.mbsy_email = @"test@test.com";
    parameters.mbsy_revenue = @1;
    
    id mockParams = [OCMockObject partialMockForObject:parameters];
    [[mockParams expect] checkForError];
    
    id mockCoreManager = [OCMockObject mockForClass:[AMBCoreDataManager class]];
    [[[mockCoreManager expect] andDo:nil] saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[parameters propertyDictionary]];
    
    // WHEN
    [self.conversion registerConversionWithParameters:parameters completion:nil];
    
    // THEN
    [mockCoreManager verify];
    [mockParams verify];
}

- (void)testSendConversions {
    // GIVEN
    [AMBValues setDeviceFingerPrintWithDictionary:@{}];
    [AMBValues setMbsyCookieWithCode:@"tEsT"];

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
    
    NSArray *array = @[mockEntity];
    id mockArray = [OCMockObject partialMockForObject:array];
    
    id mockCoreManager = [OCMockObject mockForClass:[AMBCoreDataManager class]];
    [[[mockCoreManager expect] andReturn:mockArray] getAllEntitiesFromCoreDataWithEntityName:@"AMBConversionParametersEntity"];
    [[[mockCoreManager expect] andDo:nil] deleteCoreDataObject:[OCMArg any]];
    [[[mockCoreManager expect] andDo:nil] deleteCoreDataObject:[OCMArg any]];
    
    id mockNetworkMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNetworkMgr expect] andDo:^(NSInvocation *invocation) {
        void (^success)(NSDictionary *response) = nil;
        [invocation getArgument:&success atIndex:3];
        success(@{});
    }] sendRegisteredConversion:[OCMArg any] success:[OCMArg invokeBlock] failure:[OCMArg any]];
    
    // WHEN
    [self.conversion sendConversions];
    
    // THEN
    [mockEntity verify];
    [mockNetworkMgr verify];
    [mockCoreManager verify];
}

- (void)testPayloadForConversion {
    // GIVEN
    NSDictionary *consumerDict = @{@"UID" : @"", @"insights" : @{}};
    NSDictionary *deviceDict = @{@"type" : @"test", @"ID" : @"lksdjflksdjflksdjflkajisjsjetoa23423kjlj2i3oj2lj"};
    NSDictionary *fpDict = @{@"consumer" : consumerDict, @"device" : deviceDict};
    NSDictionary *mbsyFields = @{};
    
    // WHEN
    NSDictionary *returnDict = [self.conversion payloadForConversionCallWithFP:fpDict mbsyFields:(NSMutableDictionary*)mbsyFields];
    
    // THEN
    XCTAssertEqual([[returnDict allKeys] count], 2);
}

@end
