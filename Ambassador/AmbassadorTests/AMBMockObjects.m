//
//  AMBMockObjects.m
//  Ambassador
//
//  Created by Diplomat on 10/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBMockObjects.h"

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
