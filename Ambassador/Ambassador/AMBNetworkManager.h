//
//  AMBNetworkManager.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBNetworkManager : NSObject
+ (instancetype)sharedInstance;
- (NSMutableURLRequest *)urlRequestFor:(NSString *)url body:(NSData *)b authorization:(NSString *)a;
- (void)dataTaskForRequest:(NSMutableURLRequest *)r session:(NSURLSession *)s completion:( void(^)(NSData *d, NSURLResponse *r, NSError *e))c;
@end
