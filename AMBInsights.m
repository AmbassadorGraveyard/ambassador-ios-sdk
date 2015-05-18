//
//  AMBInsights.m
//  ObjC
//
//  Created by Diplomat on 5/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBInsights.h"

@interface AMBInsights ()
@end

@implementation AMBInsights

#pragma mark - Initialization

//REMOVED IN CLEAN UP

#pragma mark - Search Interfaces

- (void)searchByEmail:(NSString *)email withErrorBlock:(void (^)(NSError *))errorBlock {
    NSString* urlString = [NSString stringWithFormat:@"https://api.augur.io/v2/user?key=%@&email=%@", super.keyString, email];
    [self makeNetworkCallWithURLString:urlString andErrorBlock:errorBlock];
}

- (void)searchByUID:(NSString*)UID withErrorBlock:(void (^)(NSError*))errorBlock {
    NSString* urlString = [NSString stringWithFormat:@"https://api.augur.io/v2/user?key=%@&uid=%@", super.keyString, UID];
    [self makeNetworkCallWithURLString:urlString andErrorBlock:errorBlock];
}

- (void)graphSearchByUID:(NSString*)UID withErrorBlock:(void (^)(NSError*))errorBlock {
    NSString* urlString = [NSString stringWithFormat:@"https://api.augur.io/graph/uid2did/v1?key=%@&uid=%@", super.keyString, UID];
    [self makeNetworkCallWithURLString:urlString andErrorBlock:errorBlock];
}

- (void)graphSearchByDID:(NSString*)DID withErrorBlock:(void (^)(NSError*))errorBlock {
    NSString* urlString = [NSString stringWithFormat:@"https://api.augur.io/graph/did2uid/v1?key=%@&did=%@", super.keyString, DID];
    [self makeNetworkCallWithURLString:urlString andErrorBlock:errorBlock];
}

#pragma mark - Network Helpers

- (void)makeNetworkCallWithURLString:(NSString*)URLString andErrorBlock:(void(^)(NSError*))errorBlock {
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:URLString]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                //Cast the response to get the status code
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
                
                //Check the response code
                if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
                    NSError* e = nil;
                    NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
                    
                    if (e != nil) {
                        errorBlock(e);
                        return;
                    } else {
                        //Success
                        //Handle JSON data somehow...
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //self.jsonResponse = jsonResponse;
#ifdef DEBUG
                            //NSLog(@"Data from insights JSON reponse:\n%@", self.jsonResponse);
#endif
                        });
                    }
                } else {
                    NSError* e = [NSError errorWithDomain:@"HTML Status Code" code:httpResponse.statusCode userInfo:nil];
                    errorBlock(e);
                    return;
                }
    }]resume];
}

@end
