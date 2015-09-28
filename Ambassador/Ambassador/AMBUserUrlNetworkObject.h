//
//  AMBUserUrlNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkObject.h"

@interface AMBUserUrlNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *campaign_uid;
@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *url;
@property BOOL has_access;
@property BOOL is_active;
@end
