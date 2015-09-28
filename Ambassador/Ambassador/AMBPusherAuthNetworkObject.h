//
//  AMBPusherAuthNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 9/24/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkObject.h"

@interface AMBPusherAuthNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *auth_type;
@property (nonatomic, strong) NSString *socket_id;
@property (nonatomic, strong) NSString *channel;
@end
