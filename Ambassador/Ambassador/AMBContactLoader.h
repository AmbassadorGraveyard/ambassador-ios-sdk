//
//  ContactLoader.h
//  iOS_Framework
//
//  Created by Diplomat on 7/8/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMBContactLoaderDelegate <NSObject>

- (void)contactsFinishedLoadingSuccessfully;
- (void)contactsFailedToLoadWithError:(NSString*)errorTitle message:(NSString *)message;

@end

@interface AMBContactLoader : NSObject

+ (AMBContactLoader*)sharedInstance;
- (void)attemptLoadWithDelegate:(id)delegate loadingFromCache:(void(^)(BOOL isCached))loadingFromCache;
- (void)forceReloadContacts;

@property NSMutableArray *phoneNumbers;
@property NSMutableArray *emailAddresses;
@property (nonatomic, weak) id<AMBContactLoaderDelegate>delegate;

@end
