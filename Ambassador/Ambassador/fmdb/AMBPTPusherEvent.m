//
//  PTPusherEvent.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "AMBPTPusherEvent.h"
#import "AMBPTJSON.h"

NSString *const AMBPTPusherDataKey    = @"data";
NSString *const AMBPTPusherEventKey   = @"event";
NSString *const AMBPTPusherChannelKey = @"channel";

@implementation AMBPTPusherEvent

+ (instancetype)eventFromMessageDictionary:(NSDictionary *)dictionary
{
  if ([dictionary[AMBPTPusherEventKey] isEqualToString:@"pusher:error"]) {
    return [[AMBPTPusherErrorEvent alloc] initWithEventName:dictionary[AMBPTPusherEventKey] channel:nil data:dictionary[AMBPTPusherDataKey]];
  }
  return [[self alloc] initWithEventName:dictionary[AMBPTPusherEventKey] channel:dictionary[AMBPTPusherChannelKey] data:dictionary[AMBPTPusherDataKey]];
}

- (id)initWithEventName:(NSString *)name channel:(NSString *)channel data:(id)data
{
  if (self = [super init]) {
    _name = [name copy];
    _channel = [channel copy];
    _timeReceived = [NSDate date];
    
    // try and deserialize the data as JSON if possible
    if ([data respondsToSelector:@selector(dataUsingEncoding:)]) {
      _data = [[[AMBPTJSON JSONParser] objectFromJSONString:data] copy];

      if (_data == nil) {
        NSLog(@"[pusher] Error parsing event data (not JSON?)");
        _data = [data copy];
      }
    }
    else {
      _data = [data copy];
    }
  }
  return self;
}


- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherEvent channel:%@ name:%@ data:%@>", self.channel, self.name, self.data];
}

@end

#pragma mark -

@implementation AMBPTPusherErrorEvent

- (NSString *)message
{
  return (self.data)[@"message"];
}

- (NSInteger)code
{
  id eventCode = (self.data)[@"code"];

  if (eventCode == nil || eventCode == [NSNull null]) {
    return PTPusherErrorUnknown;
  }
  return [eventCode integerValue];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherErrorEvent code:%ld message:%@>", (long)self.code, self.message];
}

@end
