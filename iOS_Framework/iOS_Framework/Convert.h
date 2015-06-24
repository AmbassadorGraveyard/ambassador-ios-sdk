//
//  Convert.h
//  iOS_Framework
//
//  Created by Diplomat on 6/24/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversion.h"

@interface Convert : NSObject

- (void)registerConversion:(Conversion *)conversion;
- (void)sendConversions;
- (void)removeLocalConversions;
- (BOOL)shouldSendConversions;

@end
