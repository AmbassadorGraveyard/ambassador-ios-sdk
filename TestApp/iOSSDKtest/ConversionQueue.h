//
//  ConversionQueue.h
//  iOSSDKtest
//
//  Created by Diplomat on 6/5/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversionQueue : NSObject

- (void)addToConversionQueue:(NSData *)event;
- (NSMutableArray *)getConversionQueue;
- (void)registerConversionWithEmail:(NSString *)email;
- (void)makeConversionCall;
- (void)emptyQueue;

@property BOOL dirtyQueue;

@end
