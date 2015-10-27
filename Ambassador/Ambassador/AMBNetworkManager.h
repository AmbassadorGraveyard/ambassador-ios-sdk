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
- (NSMutableURLRequest *)urlRequestFor:(NSString *)url body:(NSData *)b requestType:(NSString*)requestType authorization:(NSString *)a additionalParameters:(NSMutableDictionary*)additParams;
- (void)dataTaskForRequest:(NSMutableURLRequest *)r session:(NSURLSession *)s completion:( void(^)(NSData *d, NSURLResponse *r, NSError *e))c;

@end
