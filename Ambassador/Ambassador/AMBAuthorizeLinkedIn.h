//
//  AuthorizeLinkedIn.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkedInAuthorizeDelegate <NSObject>

- (void)userDidContinue;

@end


@interface AMBAuthorizeLinkedIn : UIViewController

@property (nonatomic, weak) id<LinkedInAuthorizeDelegate>delegate;

@end
