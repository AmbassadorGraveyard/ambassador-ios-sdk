//
//  PTBlockEventListener.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTBlockEventListener.h"

@interface AMBPTBlockEventListener : NSObject <AMBPTEventListener>
@end

@implementation AMBPTBlockEventListener {
  PTBlockEventListenerBlock _block;
  dispatch_queue_t _queue;
  BOOL _invalid;
}

- (id)initWithBlock:(PTBlockEventListenerBlock)aBlock dispatchQueue:(dispatch_queue_t)aQueue
{
  NSParameterAssert(aBlock);
  
  if ((self = [super init])) {
    _block = [aBlock copy];
    _queue = aQueue;
    _invalid = NO;
#if !OS_OBJECT_USE_OBJC
    dispatch_retain(_queue);
#endif
  }
  return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
  dispatch_release(_queue);
#endif
}

- (void)invalidate
{
  _invalid = YES;
}

- (void)dispatchEvent:(AMBPTPusherEvent *)event
{
  dispatch_async(_queue, ^{
    if (!_invalid) {
      _block(event);
    }
  });
}

@end

@implementation AMBPTPusherEventDispatcher (PTBlockEventFactory)

- (AMBPTPusherEventBinding *)addEventListenerForEventNamed:(NSString *)eventName
                                                  block:(PTBlockEventListenerBlock)block
                                                  queue:(dispatch_queue_t)queue
{
  AMBPTBlockEventListener *listener = [[AMBPTBlockEventListener alloc] initWithBlock:block dispatchQueue:queue];
  return [self addEventListener:listener forEventNamed:eventName];
}

@end
