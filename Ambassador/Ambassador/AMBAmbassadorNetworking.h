//
//  AMBAmbassadorNetworking.h
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBIdentifyNetworkObject.h"

@interface AMBAmbassadorNetworking : NSObject
+ (instancetype)sharedInstance;
- (void)sendIdentifyNetworkObj:(AMBIdentifyNetworkObject *)obj universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion;
@end
