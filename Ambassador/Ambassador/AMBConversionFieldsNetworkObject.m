//
//  AMBConversionFieldsNetworkObject.m
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBConversionFieldsNetworkObject.h"
#import "AMBErrors.h"

@implementation AMBConversionFieldsNetworkObject

- (instancetype)init {
    if (self = [super init]) {
        self.mbsy_revenue = @-1;
        self.mbsy_email = @"";
        self.mbsy_campaign = @"";
    }
    return self;
}

- (NSError *)validate {
    if ([self.mbsy_email isEqualToString:@""]   ||
        [self.mbsy_revenue isEqualToNumber:@-1] ||
        [self.mbsy_campaign isEqualToString:@""]) {
        return AMBINVETOBJError(self);
    }
    return nil;
}
@end
