//
//  AMBSMSHandler.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/10/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol Functions
@protocol AMBSMSHandlerDelegate <NSObject>

- (void)AMBSMSHandlerMessageSharedSuccessfullyWithContacts:(NSArray*)validatedContacts;
- (void)AMBSMSHandlerRequestName;
- (void)AMBSMSHandlerMessageShareFailure;

@end


// Public functions/properties
@interface AMBSMSHandler : NSObject

@property (nonatomic, weak) id<AMBSMSHandlerDelegate> delegate;

- (instancetype)initWithController:(UIViewController*)controller;
- (void)sendSMSWithMessage:(NSString*)message;
- (void)setContactArray:(NSArray*)contactArray;

@end

