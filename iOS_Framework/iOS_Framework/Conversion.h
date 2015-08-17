//
//  Conversion.h
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversionParameters.h"

@interface Conversion : NSObject

- (id)initWithKey:(NSString *)key;
- (void)registerConversionWithParameters:(ConversionParameters *)parameters;
- (void)sendConversions;

@end
