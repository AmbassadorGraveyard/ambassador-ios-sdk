//
//  AuthorizeLinkedIn.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkedInAuthorizeDelegate <NSObject>

- (void)userDidContinue;

@optional
- (void)userDidCancel;


@end



@interface AuthorizeLinkedIn : UIViewController
@property (nonatomic, weak) id<LinkedInAuthorizeDelegate>delegate;
@end
