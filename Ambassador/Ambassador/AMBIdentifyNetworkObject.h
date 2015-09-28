//
//  AMBIdentifyNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkObject.h"

@interface AMBIdentifyNetworkObject : AMBNetworkObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *campaign_id;
@property BOOL enroll;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSMutableDictionary *fp;

@end
