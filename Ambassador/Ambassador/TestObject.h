//
//  TestObject.h
//  Ambassador
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <Pusher/Pusher.h>
#import "FMDB.h"

@interface TestObject : NSObject
- (NSString *)sayHello;

+ (NSBundle *)frameworkBundle;

//- (PTPusher *)blah;

- (FMDatabase *)data;

@end
