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

- (void)sendConversion:(AMBConversionParameters *)parameters success:(void(^)())success failure:(void(^)())failure;
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
    [AMBValues setMbsyCookieWithCode:@"test"];
    [AMBValues setDeviceFingerPrintWithDictionary:@{@"testkey" : @"testvalue"}];
    
    AMBConversionParameters *parameters = [[AMBConversionParameters alloc] init];
    parameters.mbsy_campaign = @123456;
    parameters.mbsy_email = @"test@test.com";
    parameters.mbsy_revenue = @1;
    
    id mockParams = [OCMockObject partialMockForObject:parameters];
    [[mockParams expect] checkForError];
    
    [[[self.mockConversion expect] andDo:nil] sendConversion:parameters success:[OCMArg isNotNil] failure:[OCMArg isNotNil]];
    
    // WHEN
    [self.conversion registerConversionWithParameters:parameters success:^(AMBConversionParameters *conversion) {
        NSLog(@"Test result SUCCESS");
    } pending:^(AMBConversionParameters *conversion) {
        NSLog(@"Test result PENDING");
    } error:^(NSError *error, AMBConversionParameters *conversion) {
        NSLog(@"Test result ERROR");
    }];
    
    // THEN
    [self.mockConversion verify];
    [mockParams verify];
}

- (void)testConversionParamError {
    // GIVEN
    AMBConversionParameters *parameters = [[AMBConversionParameters alloc] init];
    parameters.mbsy_campaign = @123456;
    parameters.mbsy_revenue = @1;
    parameters.mbsy_email = @"";
    
    id mockError = [OCMockObject mockForClass:[NSError class]];
    
    id mockParams = [OCMockObject partialMockForObject:parameters];
    [[[mockParams expect] andReturn:mockError] checkForError];
    
    __block BOOL containsError = NO;
    
    // WHEN
    [self.conversion registerConversionWithParameters:parameters success:^(AMBConversionParameters *conversion) {
        NSLog(@"Test result SUCCESS");
    } pending:^(AMBConversionParameters *conversion) {
        NSLog(@"Test result PENDING");
    } error:^(NSError *error, AMBConversionParameters *conversion) {
        NSLog(@"Test result ERROR");
        containsError = YES;
    }];
    
    // THEN
    XCTAssertTrue(containsError);
    [mockParams verify];
}

// Skipped because OCMock can't mock NSManagedObject - https://github.com/erikdoe/ocmock/issues/339
- (void)testRetryUnsentConversions {
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
    [self.conversion retryUnsentConversions];
    
    // THEN
    [mockEntity verify];
    [mockNetworkMgr verify];
    [mockCoreManager verify];
    [mockNetworkMgr stopMocking];
}

- (void)testSendConversion {
    // GIVEN
    AMBConversionParameters *mockParams = [[AMBConversionParameters alloc] init];
    mockParams.mbsy_email = @"test@example.com";
    mockParams.mbsy_revenue = @1;
    mockParams.mbsy_campaign = @100;
    
    [AMBValues setMbsyCookieWithCode:@"test"];
    
    id mockPayloadDict = [OCMockObject mockForClass:[NSDictionary class]];
    [[[mockPayloadDict expect] andDo:nil] count];
    
    [[[self.mockConversion expect] andReturn:mockPayloadDict] payloadForConversionCallWithFP:[OCMArg isKindOfClass:[NSDictionary class]] mbsyFields:[OCMArg isKindOfClass:[NSMutableDictionary class]]];
    
    id mockNtwMgr = [OCMockObject partialMockForObject:[AMBNetworkManager sharedInstance]];
    [[[mockNtwMgr expect] andDo:nil] sendRegisteredConversion:mockPayloadDict success:[OCMArg any] failure:[OCMArg invokeBlock]];
    
    id mockCoreDataMgr = [OCMockObject mockForClass:[AMBCoreDataManager class]];
    [[[mockCoreDataMgr expect] andDo:nil] saveNewObjectToCoreDataWithEntityName:@"AMBConversionParametersEntity" valuesToSave:[mockParams propertyDictionary]];
    
    // WHEN
    [self.conversion sendConversion:mockParams success:nil failure:^{
        NSLog(@"Failure hit intentionally");
    }];
    
    // THEN
    [mockNtwMgr verify];
    [mockCoreDataMgr verify];
    
    [mockNtwMgr stopMocking];
    
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
    XCTAssertEqual([[returnDict allKeys] count], 3);
    XCTAssertEqualObjects([returnDict valueForKey:@"source"], @"ios_sdk_1_1_2");
}

- (void)testPayloadForConversionNoCUID {
    // GIVEN
    NSDictionary *consumerDict = @{};
    NSDictionary *deviceDict = @{@"type" : @"test", @"ID" : @"lksdjflksdjflksdjflkajisjsjetoa23423kjlj2i3oj2lj"};
    NSDictionary *fpDict = @{@"consumer" : consumerDict, @"device" : deviceDict};
    NSDictionary *mbsyFields = @{};
    
    // WHEN
    NSDictionary *returnDict = [self.conversion payloadForConversionCallWithFP:fpDict mbsyFields:(NSMutableDictionary*)mbsyFields];
    
    // THEN
    XCTAssertEqual([[returnDict allKeys] count], 3);
    XCTAssertEqualObjects([returnDict valueForKey:@"source"], @"ios_sdk_1_1_2");
}


- (void)testPayloadForConversionNoInsights {
    // GIVEN
    NSDictionary *consumerDict = @{@"UID" : @""};
    NSDictionary *deviceDict = @{@"type" : @"test", @"ID" : @"lksdjflksdjflksdjflkajisjsjetoa23423kjlj2i3oj2lj"};
    NSDictionary *fpDict = @{@"consumer" : consumerDict, @"device" : deviceDict};
    NSDictionary *mbsyFields = @{};
    
    // WHEN
    NSDictionary *returnDict = [self.conversion payloadForConversionCallWithFP:fpDict mbsyFields:(NSMutableDictionary*)mbsyFields];
    
    // THEN
    XCTAssertEqual([[returnDict allKeys] count], 3);
    XCTAssertEqualObjects([returnDict valueForKey:@"source"], @"ios_sdk_1_1_2");
}

@end
