//
//  AMBNetworkManager.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkManager.h"
#import "AMBErrors.h"

@implementation AMBNetworkManager

+ (instancetype)sharedInstance {
    static AMBNetworkManager* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ _sharedInsance = [[AMBNetworkManager alloc] init]; });
    return _sharedInsance;
}

- (NSMutableURLRequest *)urlRequestFor:(NSString *)url body:(NSData *)b requestType:(NSString*)requestType authorization:(NSString *)a additionalParameters:(NSMutableDictionary*)additParams {
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    r.HTTPMethod = requestType;
    [r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [r setValue:a forHTTPHeaderField:@"Authorization"];
    
    // Sets header values passed in with dictionary to additionParameters
    if (additParams || additParams.count > 0) {
        NSArray *keyArray = additParams.allKeys;
        
        for (int i = 0; i < additParams.count; i++) {
            [r setValue:[additParams valueForKey:keyArray[i]] forHTTPHeaderField:keyArray[i]];
        }
    }

    if (b) { r.HTTPBody = b; }

    return r;
}

- (void)dataTaskForRequest:(NSMutableURLRequest *)r session:(NSURLSession *)s completion:( void(^)(NSData *d, NSURLResponse *r, NSError *e))c {
    [[s dataTaskWithRequest:r completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
        NSError *e = (code >= 200 && code < 300)? nil : AMBBADRESPError(code, data);
        e = error? error : e;
        if (c) { dispatch_async(dispatch_get_main_queue(), ^{ c(data, response, e); }); }
    }] resume];
}

@end
