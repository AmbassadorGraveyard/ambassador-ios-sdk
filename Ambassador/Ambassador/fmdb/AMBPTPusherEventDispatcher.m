//
//  PTPusherEventDispatcher.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherEventDispatcher.h"
#import "AMBPTPusherEvent.h"

@interface AMBPTPusherEventBinding ()
- (void)invalidate;
@end

@implementation AMBPTPusherEventDispatcher {
  NSMutableDictionary *_bindings;
}

- (id)init
{
  if ((self = [super init])) {
    _bindings = [[NSMutableDictionary alloc] init];
  }
  return self;
}

#pragma mark - Managing event listeners

- (AMBPTPusherEventBinding *)addEventListener:(id<AMBPTEventListener>)listener forEventNamed:(NSString *)eventName
{
  NSMutableArray *bindingsForEvent = _bindings[eventName];
  
  if (bindingsForEvent == nil) {
    bindingsForEvent = [NSMutableArray array];
    _bindings[eventName] = bindingsForEvent;
  }
  AMBPTPusherEventBinding *binding = [[AMBPTPusherEventBinding alloc] initWithEventListener:listener eventName:eventName];
  [bindingsForEvent addObject:binding];
  
  return binding;
}

- (void)removeBinding:(AMBPTPusherEventBinding *)binding
{
  NSMutableArray *bindingsForEvent = _bindings[binding.eventName];
  
  if ([bindingsForEvent containsObject:binding]) {
    [binding invalidate];
    [bindingsForEvent removeObject:binding];
  }
}

- (void)removeAllBindings
{
  for (NSArray *eventBindings in [_bindings allValues]) {
    for (AMBPTPusherEventBinding *binding in eventBindings) {
	    [binding invalidate];
	  }
  }
  [_bindings removeAllObjects];
}

#pragma mark - Dispatching events

- (void)dispatchEvent:(AMBPTPusherEvent *)event
{
  for (AMBPTPusherEventBinding *binding in _bindings[event.name]) {
    [binding dispatchEvent:event];
  }
}

@end

@implementation AMBPTPusherEventBinding {
  id<AMBPTEventListener> _eventListener;
}

- (id)initWithEventListener:(id<AMBPTEventListener>)eventListener eventName:(NSString *)eventName
{
  if ((self = [super init])) {
    _eventName = [eventName copy];
    _eventListener = eventListener;
  }
  return self;
}

- (void)invalidate
{
  if ([_eventListener respondsToSelector:@selector(invalidate)]) {
    [_eventListener invalidate];
  }
}

- (void)dispatchEvent:(AMBPTPusherEvent *)event
{
  [_eventListener dispatchEvent:event];
}

@end
