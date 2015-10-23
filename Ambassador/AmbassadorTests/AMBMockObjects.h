//
//  AMBMockObjects.h
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBNetworkObject.h"

@interface AMBMockObject : NSObject
@end



@interface AMBMockUserObjects : AMBMockObject
- (NSMutableDictionary *)mockUser;
@end



@interface AMBMockShareTrackObject : AMBMockObject
// valid objects
+ (AMBShareTrackNetworkObject *)validFacebookShare;
+ (AMBShareTrackNetworkObject *)validTwitterShare;
+ (AMBShareTrackNetworkObject *)validLinkedInShare;
+ (AMBShareTrackNetworkObject *)validSMSShare;
+ (AMBShareTrackNetworkObject *)validEmailShare;

// invalid objects
+ (AMBShareTrackNetworkObject *)invalidServiceTypeShare;
+ (AMBShareTrackNetworkObject *)invalidShortCodeShare;
+ (AMBShareTrackNetworkObject *)invalidRecipientEmailShare;
+ (AMBShareTrackNetworkObject *)invalidRecipientUsernameShare;

+ (NSString *)shortCodeValid:(BOOL)valid;
+ (NSMutableArray *)recipientUsernameValid:(BOOL)valid;
+ (NSMutableArray *)recipientEmailValid:(BOOL)valid;
+ (NSString *)invalidSocialName;

@end
