//
//  AMBUserNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkObject.h"

@interface AMBUserNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableArray *urls;
@end
