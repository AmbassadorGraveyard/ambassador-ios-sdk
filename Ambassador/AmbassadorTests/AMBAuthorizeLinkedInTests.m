//
//  AMBAuthorizeLinkedInTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/26/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMBAuthorizeLinkedIn.h"

@interface AMBAuthorizeLinkedIn (Test)

- (void)viewDidLoad;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)saveValuesFromQueryParams:(NSArray*)queryParameters;

@end


@interface AMBAuthorizeLinkedInTests : XCTestCase

@property (nonatomic, strong) AMBAuthorizeLinkedIn * ambAuthorizeLinkedin;

@end

@implementation AMBAuthorizeLinkedInTests

- (void)setUp {
    [super setUp];
    if (!self.ambAuthorizeLinkedin) {
        self.ambAuthorizeLinkedin = [[AMBAuthorizeLinkedIn alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testViewDidLoad {
    // GIVEN
    NSString *titleString = @"Authorize LinkedIn";
    
    // WHEN
    [self.ambAuthorizeLinkedin viewDidLoad];
    
    // THEN
    XCTAssertEqualObjects(titleString, self.ambAuthorizeLinkedin.navigationItem.title);
}

@end
