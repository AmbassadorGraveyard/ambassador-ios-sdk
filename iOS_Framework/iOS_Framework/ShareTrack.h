//
//  ShareTrack.h
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "JSONModel.h"

@interface ShareTrack : JSONModel

@property (nonatomic, strong) NSString *short_code;
@property (nonatomic, strong) NSString *recipient_email;
@property (nonatomic, strong) NSString *social_name;
@property (nonatomic, strong) NSString *recipient_username;

@end

@interface ShareTrackBulk : JSONModel

@property (nonatomic, strong) NSMutableArray<ShareTrack *> *bulk;

@end
