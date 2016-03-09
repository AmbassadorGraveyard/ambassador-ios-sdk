//
//  LinkedInShare.m
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBLinkedInShare.h"
#import "AMBNetworkManager.h"
#import "AMBThemeManager.h"

@implementation AMBLinkedInShare


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LinkedIn";
    self.textView.text = self.defaultMessage;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textView becomeFirstResponder];
}


#pragma mark - SLComposeView Delegate 

- (void)didSelectPost {
    [[AMBNetworkManager sharedInstance] shareToLinkedInWithMessage:self.textView.text success:^(NSString *accessToken) {
        [self.delegate userDidPostFromService:@"LinkedIn"];
    } failure:^(NSString *error) {
        [self.delegate networkError:@"Posting Error" message:@"Your post couldn't be completed due to a network error"];
    }];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectCancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
