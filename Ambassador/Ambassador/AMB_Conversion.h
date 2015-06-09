//
//  AMB_Conversion.h
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMB_Conversion : NSObject

- (BOOL)registerConversion;
- (BOOL)registerConversionWithEmail:(NSString *)email;

@end
