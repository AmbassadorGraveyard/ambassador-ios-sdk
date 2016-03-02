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
    NSDictionary *payload = @{ @"comment" : [NSString stringWithFormat:@"%@ %@", self.textView.text, self.shortURL], @"visibility" : @{ @"code" : @"connections-only" } };
    [[AMBNetworkManager sharedInstance] shareToLinkedinWithPayload:payload success:^{
        [self.delegate userDidPostFromService:@"LinkedIn"];
    } needsReauthentication:^{
        [self.delegate userMustReauthenticate];
    } failure:^(NSString *error) {
        [self.delegate networkError:@"Posting Error" message:@"Your post couldn't be completed do to a network error"];
    }];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectCancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
