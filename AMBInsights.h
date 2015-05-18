//
//  AMBInsights.h
//  ObjC
//
//  Created by Diplomat on 5/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBBase.h"

@interface AMBInsights : AMBBase

- (void)searchByEmail:(NSString*)email withErrorBlock:(void (^)(NSError*))errorBlock;
- (void)searchByUID:(NSString*)email withErrorBlock:(void (^)(NSError*))errorBlock;
- (void)graphSearchByUID:(NSString*)UID withErrorBlock:(void (^)(NSError*))errorBlock;
- (void)graphSearchByDID:(NSString*)DID withErrorBlock:(void (^)(NSError*))errorBlock;

@property NSDictionary* jsonResponse;

@end
