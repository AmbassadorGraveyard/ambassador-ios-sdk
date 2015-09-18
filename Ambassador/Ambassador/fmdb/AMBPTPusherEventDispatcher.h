//
//  PTPusherEventDispatcher.h
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBPTEventListener.h"

@class AMBPTPusherEventBinding;

@interface AMBPTPusherEventDispatcher : NSObject <AMBPTEventListener> 

@property (nonatomic, readonly) NSDictionary *bindings;

- (AMBPTPusherEventBinding *)addEventListener:(id<AMBPTEventListener>)listener forEventNamed:(NSString *)eventName;
- (void)removeBinding:(AMBPTPusherEventBinding *)binding;
- (void)removeAllBindings;
@end

/** Represents an event binding created when calling one of the binding methods defined
  in the PTPusherEventBindings protocol.
 
  You should keep a reference to binding objects if you need to remove them later. 
 
 For more information on managing event bindings, see the README.
 */
@interface AMBPTPusherEventBinding : NSObject <AMBPTEventListener>

/** The event name this binding is bound to.
 */
@property (nonatomic, readonly) NSString *eventName;

/** Returns YES if this binding is still attached to its event publisher.
  
 Retained references to bindings can become invalid as a result of another object
 calling removeBinding: with this binding or removeAllBindings.
 
 You can safely discard invalid binding instances.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

- (id)initWithEventListener:(id<AMBPTEventListener>)eventListener eventName:(NSString *)eventName;
@end
