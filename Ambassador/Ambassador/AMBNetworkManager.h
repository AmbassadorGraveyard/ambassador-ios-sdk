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

//static NSURLSession * urlSession;
@property (nonatomic, strong) NSURLSession * urlSession;

+ (instancetype)sharedInstance;

// Network calls
- (void)sendIdentifyForCampaign:(NSString*)campaign shouldEnroll:(BOOL)enroll success:(void(^)(NSString *response))success failure:(void(^)(NSString *error))failure;
- (void)sendShareTrackForServiceType:(AMBSocialServiceType)socialType contactList:(NSMutableArray*)contactList success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)bulkShareSmsWithMessage:(NSString*)message phoneNumbers:(NSArray*)phoneNumbers success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)bulkShareEmailWithMessage:(NSString*)message emailAddresses:(NSArray*)addresses success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)updateNameWithFirstName:(NSString*)firstName lastName:(NSString*)lastName success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)updateAPNDeviceToken:(NSString*)deviceToken success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (void)sendRegisteredConversion:(NSDictionary*)conversionDict success:(void(^)(NSDictionary *response))success failure:(void(^)(NSInteger statusCode, NSData *data))failure;
- (void)getPusherSessionWithSuccess:(void(^)(NSDictionary *response))success noSDKAccess:(void(^)())noSDKAccess failure:(void(^)(NSString *error))failure;
- (void)getLargePusherPayloadFromUrl:(NSString*)url success:(void(^)(NSDictionary *response))success failure:(void(^)(NSString *error))failure;
- (NSData *)getUrlInformationWithSuccess:(NSString*)shortCode;

// LinkedIn Requests
- (void)getCompanyUIDWithSuccess:(void(^)(NSString *companyUID))success failure:(void(^)(NSString *error))failure;
- (void)getLinkedInClientValuesWithUID:(NSString*)companyUID success:(void(^)(NSDictionary *clientValues))success failure:(void(^)(NSString *error))failure;
- (void)getLinkedInAccessTokenWithPopupValue:(NSString*)popupValue success:(void(^)(NSString *accessToken))success failure:(void(^)(NSString *error))failure;
- (void)shareToLinkedInWithMessage:(NSString*)message success:(void(^)(NSString *successMessage))success failure:(void(^)(NSString *error))failure;

// Welcome Screen Requests
- (void)getReferrerInformationWithSuccess:(void(^)(NSDictionary *referrerInfo))success failure:(void(^)(NSString *error))failure;

@end
