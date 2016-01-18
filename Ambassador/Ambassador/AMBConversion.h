//
//  Conversion.h
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBConversionParameters.h"

@interface AMBConversion : NSObject <NSURLSessionDelegate>

- (void)registerConversionWithParameters:(AMBConversionParameters *)parameters completion:(void (^)(NSError *error))completion;
- (void)sendConversions;

@end
