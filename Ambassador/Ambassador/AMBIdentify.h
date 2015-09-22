//
//  Identify.h
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMBIdentifyDelegate <NSObject>

@optional
- (void)identifyDataWasRecieved:(NSMutableDictionary *)data;
- (void)ambassadorDataWasRecieved:(NSMutableDictionary *)data;

@end



@interface AMBIdentify : NSObject

- (id)initWithUniversalToken:(NSString *)universalToken universalID:(NSString *)universalID;
- (void)identifyWithEmail:(NSString *)email;
@property NSMutableDictionary *identifyData;
@property NSString *pusherChannelName;
@property (nonatomic, weak) id<AMBIdentifyDelegate>delegate;
- (void)getInsightsDataForUID:(NSString *)UID success:(void (^)(NSMutableDictionary *response))success fail:(void (^)(NSError *error))fail;

@end