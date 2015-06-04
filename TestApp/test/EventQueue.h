//
//  EventQueue.h
//  test
//
//  Created by Diplomat on 6/4/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventObject.h"

@interface EventQueue : NSObject

- (BOOL)pushEvent:(EventObject *)event;
- (BOOL)emptyQueue;
- (NSMutableArray *)getQueue;
- (id)initWithQueueName:(NSString *)queueName;

@end
