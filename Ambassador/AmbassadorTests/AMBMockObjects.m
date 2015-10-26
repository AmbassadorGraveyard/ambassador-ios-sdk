//
//  AMBMockObjects.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBMockObjects.h"
#import "AMBOptions.h"

@implementation AMBMockObject
@end



@implementation AMBMockUserObjects
- (NSMutableDictionary *)mockUser {
    NSMutableDictionary *returnVal = [[NSMutableDictionary alloc] init];
    [returnVal setValue:@"John" forKey:@"first_name"];
    [returnVal setValue:@"Doe" forKey:@"last_name"];
    [returnVal setValue:[NSNull null] forKey:@"phone"];
    [returnVal setValue:@"John@Doe.com" forKey:@"email"];
    [returnVal setValue:[NSNull null] forKey:@"url"];
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSMutableDictionary *url = [[NSMutableDictionary alloc] init];
    [url setValue:@123 forKey:@"campaign_uid"];
    [url setValue:@"wxyz" forKey:@"short_code"];
    [url setValue:@"subject line" forKey:@"subject"];
    [url setValue:@"www.com" forKey:@"url"];
    [url setValue:@YES forKey:@"has_access"];
    [url setValue:@NO forKey:@"is_active"];
    
    [urls addObject:url];
    [returnVal setValue:urls forKey:@"urls"];
    return returnVal;
}
@end

@implementation AMBMockShareTrackObject
+ (NSString *)shortCodeValid:(BOOL)valid {
    return valid? @"lb6n" : @"siiejjkfhhdk";
}

+ (NSMutableArray *)recipientEmailValid:(BOOL)valid {
    NSArray *validArray = @[
                            @"a@b.com",
                            @"b@c.com"
                            ];
    NSArray *invalidArray = @[
                              @"www.icloud.com",
                              @"www.b.com"
                              ];
    return [NSMutableArray arrayWithArray:(valid)? validArray : invalidArray];
}

+ (NSMutableArray *)recipientUsernameValid:(BOOL)valid {
    NSArray *validArray = @[
                            @"1234567",
                            @"1234567890",
                            @"01234567890"
                            ];
    NSArray *invalidArray = @[
                              @"+(1)2-34",
                              @"b.com"
                              ];
    return [NSMutableArray arrayWithArray:(valid)? validArray : invalidArray];
}

+ (NSString *)invalidSocialName {
    return @"invalidSocialName123";
}

// valid objects
+ (AMBShareTrackNetworkObject *)validFacebookShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeFacebook);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)validTwitterShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeTwitter);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)validLinkedInShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeLinkedIn);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)validSMSShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeSMS);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    o.recipient_username = [AMBMockShareTrackObject recipientUsernameValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)validEmailShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeEmail);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    o.recipient_email = [AMBMockShareTrackObject recipientEmailValid:YES];
    return o;
}

// invalid objects
+ (AMBShareTrackNetworkObject *)invalidServiceTypeShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = [AMBMockShareTrackObject invalidSocialName];
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)invalidShortCodeShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeSMS);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:NO];
    o.recipient_username = [AMBMockShareTrackObject recipientUsernameValid:YES];
    return o;
}

+ (AMBShareTrackNetworkObject *)invalidRecipientEmailShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeEmail);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    o.recipient_email = [AMBMockShareTrackObject recipientEmailValid:NO];
    return o;
}

+ (AMBShareTrackNetworkObject *)invalidRecipientUsernameShare {
    AMBShareTrackNetworkObject *o = [[AMBShareTrackNetworkObject alloc] init];
    o.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeSMS);
    o.short_code = [AMBMockShareTrackObject shortCodeValid:YES];
    o.recipient_username = [AMBMockShareTrackObject recipientUsernameValid:NO];
    return o;
}

@end
