#import <Foundation/Foundation.h>
#import "AMB_Identify.h"
#import "AMB_Conversion.h"
#import <XCTest/XCTest.h>

@interface AMBASSADORConversionTests : XCTestCase

@property AMB_Identify*ident;
@property AMB_Conversion*con;

@end

@implementation AMBASSADORConversionTests

- (void)testInitialization
{
    self.ident = [[AMB_Identify alloc] init];
    XCTAssertNotNil(self.ident, @"Conversion didn't initialize");
}

- (void)testIdentify
{
    self.ident = [[AMB_Identify alloc] init];
    XCTAssertTrue([self.ident identify], @"Identify should return YES");
}

- (void)testConversionInitialization
{
    self.con = [[AMB_Conversion alloc] init];
    XCTAssertNotNil(self.con, @"Conversion didn't initialize");
}

- (void)testConversionRegister
{
    self.con = [[AMB_Conversion alloc] init];
    [self.con registerConversion];
}

@end
