//
//  LinkedInShare.h
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Social/Social.h>

@protocol AMBShareServiceDelegate <NSObject>

- (void)userDidPostFromService:(NSString *)service;
- (void)networkError:(NSString *)title message:(NSString *)message;
- (void)userMustReauthenticate;

@end

@interface AMBLinkedInShare : SLComposeServiceViewController

@property NSString *defaultMessage;
@property NSString *shortCode;
@property NSString *shortURL;
@property (weak)id<AMBShareServiceDelegate>delegate;

@end
