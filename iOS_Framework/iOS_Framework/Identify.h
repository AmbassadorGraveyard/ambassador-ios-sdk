//
//  Identify.h
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IdentifyDelegate <NSObject>

@optional
- (void)identifyDataWasRecieved:(NSMutableDictionary *)data;
- (void)insightsDataWasRecieved:(NSMutableDictionary *)data;
- (void)ambassadorDataWasRecieved:(NSMutableDictionary *)data;

@end



@interface Identify : NSObject

- (id)initWithKey:(NSString *)key;
- (void)identifyWithEmail:(NSString *)email;
@property NSMutableDictionary *identifyData;
@property NSString *pusherChannelName;
@property (nonatomic, weak) id<IdentifyDelegate>delegate;

@end