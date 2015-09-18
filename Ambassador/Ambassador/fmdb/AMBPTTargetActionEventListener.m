//
//  PTTargetActionEventListener.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTTargetActionEventListener.h"

@interface AMBPTTargetActionEventListener : NSObject <AMBPTEventListener>
@end

@implementation AMBPTTargetActionEventListener {
  id _target;
  SEL _action;
  BOOL _invalid;
}

- (id)initWithTarget:(id)aTarget action:(SEL)aSelector
{
  if (self = [super init]) {
    _target = aTarget;
    _action = aSelector;
    _invalid = NO;
  }
  return self;
}

- (void)invalidate
{
  _invalid = YES;
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"<PTEventListener target:%@ selector:%@>", _target, NSStringFromSelector(_action)];
}

- (void)dispatchEvent:(AMBPTPusherEvent *)event;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  if (!_invalid) {
    [_target performSelector:_action withObject:event];
  }
#pragma clang diagnostic pop
}

@end

@implementation AMBPTPusherEventDispatcher (PTTargetActionFactory)

- (AMBPTPusherEventBinding *)addEventListenerForEventNamed:(NSString *)eventName target:(id)target action:(SEL)action
{
  AMBPTTargetActionEventListener *listener = [[AMBPTTargetActionEventListener alloc] initWithTarget:target action:action];
  return [self addEventListener:listener forEventNamed:eventName];
}

@end
