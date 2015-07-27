//
//  LinkedInShareViewController.h
//  iOS_Framework
//
//  Created by Diplomat on 7/17/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkedInShareDelegate <NSObject>

- (void)userDidPost:(NSMutableDictionary *)data;
- (void)userMustReauthenticate;

@end


@interface LinkedInShareViewController : UIViewController

- (id)initWithDefaultMessage:(NSString *)message;
@property (nonatomic, weak) id<LinkedInShareDelegate>delegate;
- (BOOL)isAuthorized;

@end
