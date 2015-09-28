//
//  AMBPusherManager.h
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBPusher.h"

@interface AMBPusherManager : NSObject
- (instancetype)initWith:(NSString *)uToken universalID:(NSString *)uID;
- (void)subscribe:(NSString *)did completion:(void(^)(AMBPTPusherChannel *, NSError *))completion;
- (void)bindToChannelEvent:(NSString *)event handler:(void(^)(AMBPTPusherEvent *))handler;
@end
