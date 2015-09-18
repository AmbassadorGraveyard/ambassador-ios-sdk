//
//  PTEventListener.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AMBPTPusherEvent;

@protocol AMBPTEventListener <NSObject>

- (void)dispatchEvent:(AMBPTPusherEvent *)event;

@optional

- (void)invalidate;

@end
