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

@interface AMBAuthorizeLinkedIn () <UIWebViewDelegate, UIAlertViewDelegate>

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


#pragma mark - WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Parse the URL string delimiting at "?"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@"?"];
    
    if ([[urlRequestComponents firstObject] isEqualToString:[AMBValues getLinkedInAuthCallbackUrl]] && urlRequestComponents.count > 1) { // Checks if the webview is redirecting to the callback url and that there are parameters
        NSArray *queryParameters = [urlRequestComponents[1] componentsSeparatedByString:@"&"]; // Creates an array of query parameters and corresponding values Ex:test=value, test2=value2
        [self saveValuesFromQueryParams:queryParameters];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        [[AMBUtilities sharedInstance] hideLoadingView];
    }
}


#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Helper Functions

- (void)saveValuesFromQueryParams:(NSArray*)queryParameters {
    for (int i = 0; i < queryParameters.count; ++i) {
        NSArray *queryPair = [queryParameters[i] componentsSeparatedByString:@"="];
        
        if ([[queryPair firstObject] isEqualToString:@"error"]) { // If a random error occurs, the user is alerted and popped back to try again
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to login" message:@"There was an error while logging into LinkedIn, please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [errorAlert show];
            return;
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

@end
