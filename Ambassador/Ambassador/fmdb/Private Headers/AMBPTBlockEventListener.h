//
//  PTBlockEventListener.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBPTEventListener.h"
#import "AMBPTPusherEventDispatcher.h"

typedef void (^PTBlockEventListenerBlock)(AMBPTPusherEvent *);

@interface AMBPTPusherEventDispatcher (PTBlockEventFactory)

- (AMBPTPusherEventBinding *)addEventListenerForEventNamed:(NSString *)eventName 
                                block:(PTBlockEventListenerBlock)block 
                                queue:(dispatch_queue_t)queue;

@end

