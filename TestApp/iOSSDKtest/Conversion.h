//
//  Conversion.h
//  iOSSDKtest
//
//  Created by Diplomat on 6/9/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conversion : NSObject

@property NSMutableArray *queue;
- (void)push:(id)object;
- (id)pop;
- (void)empty;
- (void)makeNetworkCall;

@end
