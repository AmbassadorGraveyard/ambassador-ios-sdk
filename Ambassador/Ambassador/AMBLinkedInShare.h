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

@property (nonatomic, strong) NSString *defaultMessage;
@property (nonatomic, strong) NSString *shortCode;
@property (nonatomic, strong) NSString *shortURL;
@property (nonatomic, weak) id <AMBShareServiceDelegate> delegate;

@end
