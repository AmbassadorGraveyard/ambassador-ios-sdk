//
//  ContactLoader.h
//  iOS_Framework
//
//  Created by Diplomat on 7/8/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactLoaderDelegate <NSObject>

- (void)contactsFailedToLoadWithError:(NSString*)errorTitle message:(NSString *)message;

@end

@interface ContactLoader : NSObject

- (id)initWithDelegate:(id<ContactLoaderDelegate>)delegate;
@property NSMutableArray *phoneNumbers;
@property NSMutableArray *emailAddresses;
@property (nonatomic, weak) id<ContactLoaderDelegate>delegate;

@end
