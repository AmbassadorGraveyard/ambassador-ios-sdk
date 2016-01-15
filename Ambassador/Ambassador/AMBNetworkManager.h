//
//  AMBNetworkManager.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBNetworkObject.h"
#import "AMBOptions.h"

@interface AMBNetworkManager : NSObject <NSURLSessionDataDelegate>

+ (instancetype)sharedInstance;

// Network calls
- (void)sendIdentifyForCampaign:(NSString*)campaign shouldEnroll:(BOOL)enroll success:(void(^)(NSString *response))success failure:(void(^)(NSString *error))failure;
- (void)sendShareTrackForServiceType:(AMBSocialServiceType)socialType contactList:(NSMutableArray*)contactList success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)getLinkedInRequestTokenWithKey:(NSString*)key success:(void(^)())success failure:(void(^)(NSString *error))failure;
- (void)checkForInvalidatedTokenWithCompletion:(void(^)())complete;
- (void)shareToLinkedinWithPayload:(NSDictionary*)payload success:(void(^)())success needsReauthentication:(void(^)())shouldReauthenticate failure:(void(^)(NSString *error))failure;
- (void)bulkShareSmsWithMessage:(NSString*)message phoneNumbers:(NSArray*)phoneNumbers success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)bulkShareEmailWithMessage:(NSString*)message emailAddresses:(NSArray*)addresses success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)updateNameWithFirstName:(NSString*)firstName lastName:(NSString*)lastName success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)sendRegisteredConversion:(NSDictionary*)conversionDict success:(void(^)(NSDictionary *response))success failure:(void(^)(NSInteger statusCode, NSData *data))failure;
- (void)getPusherSessionWithSuccess:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)getLargePusherPayloadFromUrl:(NSString*)url success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;

@end
