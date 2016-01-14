//
//  AuthorizeLinkedIn.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBAuthorizeLinkedIn.h"
#import "AMBConstants.h"
#import "AMBNetworkManager.h"

@interface AMBAuthorizeLinkedIn () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AMBAuthorizeLinkedIn

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Authorize LinkedIn";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[AMBValues getLinkedInAuthorizationUrl]]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [[AMBUtilities sharedInstance] showLoadingScreenForView:self.view];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat offset = [AMBUtilities getOffsetForRotation:self toOrientation:toInterfaceOrientation];
    [[AMBUtilities sharedInstance] rotateLoadingView:self.view widthOffset:offset];
}


#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //Parse the URL string delimiting at "?"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@"?"];
    if ([[urlRequestComponents firstObject] isEqualToString:[AMBValues getLinkedInAuthCallbackUrl]])
    {
        self.webView.hidden = YES;
        if (urlRequestComponents.count > 1)
        {
            NSArray *queryParameters = [urlRequestComponents[1] componentsSeparatedByString:@"&"];
            for (int i = 0; i < queryParameters.count; ++i)
            {
                NSArray *queryPair = [queryParameters[i] componentsSeparatedByString:@"="];
                if ([[queryPair firstObject] isEqualToString:@"error"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                if ([[queryPair firstObject] isEqualToString:@"code"]) {
                    [[AMBNetworkManager sharedInstance] getLinkedInRequestTokenWithKey:[NSString stringWithString:[queryPair lastObject]] success:^{
                        DLog(@"Get Linkedin Request Token SUCCESSFUL!")
                        [self.delegate userDidContinue];
                    } failure:^(NSString *error) {
                        DLog(@"Get Linkedin Request Token FAILED with response - %@", error)
                    }];
                }
            }
        }
        return NO;
    }
    return YES;
}


#pragma mark - WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        [[AMBUtilities sharedInstance] hideLoadingView];
    }
}


@end
