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
    self.devToken = @"SDKToken 9de5757f801ca60916599fa3f3c92131b0e63c6a";
    self.devID = @"abfd1c89-4379-44e2-8361-ee7b87332e32";
    
    self.prodToken = @"SDKToken 84444f4022a8cd4fce299114bc2e323e57e32188";
    self.prodID = @"830883cd-b2a7-449c-8a3c-d1850aa8bc6b";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
