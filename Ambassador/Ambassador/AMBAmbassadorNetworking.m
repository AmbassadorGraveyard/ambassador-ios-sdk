//
//  AMBAmbassadorNetworking.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBAmbassadorNetworking.h"
#import "AMBErrors.h"
#import "AMBConversionNetworkObject.h"

@implementation AMBAmbassadorNetworking
#pragma mark - Initialization
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Specific Network call wrappers
- (void)sendIdentifyNetworkObj:(AMBIdentifyNetworkObject *)obj universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion {
    [[AMBAmbassadorNetworking sharedInstance] sendNetworkObject:obj url:[[AMBAmbassadorNetworking sharedInstance] sendIdentifyURL] universalToken:uToken universalID:uID completion:completion];
}

- (void)sendConversionObj:(AMBConversionNetworkObject *)obj universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion {
    [[AMBAmbassadorNetworking sharedInstance] sendNetworkObject:obj url:[[AMBAmbassadorNetworking sharedInstance] sendConversionURL] universalToken:uToken universalID:uID completion:completion];
}


#pragma mark - Network template functions
- (void)sendNetworkObject:(AMBNetworkObject *)obj url:(NSString *)url universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion {    [[AMBAmbassadorNetworking sharedInstance] ambassadorURLRequestFor:url body:[obj dictionaryForm] universalToken:uToken universalID:uID completion:^(NSMutableURLRequest *request, NSError *e) {
        if (e) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, nil, e); });
            }
            return;
        }
        [[AMBAmbassadorNetworking sharedInstance] createDataTaskForRequest:request completion:completion];
    }];
}

- (void)ambassadorURLRequestFor:(NSString *)url body:(NSMutableDictionary *)body universalToken:(NSString *)uToken universalID:(NSString *)uID completion:(void (^)(NSMutableURLRequest *, NSError *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:uToken forHTTPHeaderField:@"Authorization"];
    __autoreleasing NSError *e = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&e];
    request.HTTPBody = bodyData;
    if (completion) {
        completion(request, e);
    }
}

- (void)createDataTaskForRequest:(NSMutableURLRequest *)request completion:(void (^)(NSData *d, NSURLResponse *r, NSError *e))completion {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(data, response, error); });
            }
            return;
        }
        
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code >= 200 && code < 300) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(data, response, error); });
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(data, response, AMBBADRESPError(code, data));
                });
            }
        }
    }] resume];
}


#pragma mark - Url returns
- (NSString *)sendIdentifyURL {
    if (YES)
        return @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/";
    else
        return @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/"; //TODO: change to production
}

- (NSString *)sendConversionURL {
    if (YES)
        return @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/";
    else
        return @"https://dev-ambassador-api.herokuapp.com/universal/action/conversion/"; //TODO: change to production
}

@end
