//
//  AMBTests.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBTests.h"

@implementation AMBTests

- (void)setUp {
    [super setUp];
    self.devToken = @"SDKToken ***REMOVED***";
    self.devID = @"***REMOVED***";
    
    self.prodToken = @"SDKToken ***REMOVED***";
    self.prodID = @"***REMOVED***";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
