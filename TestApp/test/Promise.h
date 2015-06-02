//
//  Promise.h
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Promise : NSObject

- (Promise *)fail:(void (^)(void))fail;
- (Promise *)then:(void (^)(void))success;

- (void)reject;

- (void)resolve;
+ (Promise *)defer;
@end
