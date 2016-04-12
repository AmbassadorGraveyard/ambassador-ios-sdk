//
//  AuthorizeLinkedIn.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBAuthorizeLinkedIn.h"
#import "AMBNetworkManager.h"
#import "AMBThemeManager.h"
#import "AMBUtilities.h"

@interface AMBAuthorizeLinkedIn () <UIWebViewDelegate, AMBUtilitiesDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString * popupString;

@end


@implementation AMBAuthorizeLinkedIn


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Authorize LinkedIn";
    self.navigationController.navigationBar.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
    [[AMBUtilities sharedInstance] showLoadingScreenForView:self.view];
    [AMBUtilities sharedInstance].delegate = self;
    [self getLinkedInClientInfo];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[AMBUtilities sharedInstance] rotateLoadingView:self.view orientation:toInterfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AMBUtilities sharedInstance] hideLoadingView];
}


#pragma mark - WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Parse the URL string delimiting at "?"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@"?"];
    
    NSString *authenticateUrl = [AMBValues isProduction] ? @"https://api.getenvoy.co/oauth/authenticate/" : @"https://dev-envoy-api.herokuapp.com/oauth/authenticate/";
    NSString *authUrl = [AMBValues isProduction] ? @"https://api.getenvoy.co/auth/linkedin/auth" : @"https://dev-envoy-api.herokuapp.com/auth/linkedin/auth";
    
    if (([[urlRequestComponents firstObject] isEqualToString:authUrl] || [[urlRequestComponents firstObject] isEqualToString:authenticateUrl]) && urlRequestComponents.count > 1) { // Checks if the webview is redirecting to the callback url and that there are parameters
        NSArray *queryParameters = [urlRequestComponents[1] componentsSeparatedByString:@"&"]; // Creates an array of query parameters and corresponding values Ex:test=value, test2=value2
        [self saveValuesFromQueryParams:queryParameters];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[AMBUtilities sharedInstance] hideLoadingView];
}


#pragma mark - Utilities Delegate

- (void)okayButtonClickedForUniqueID:(NSString *)uniqueID {
    if ([uniqueID isEqualToString:@"linkedError"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Helper Functions

- (void)saveValuesFromQueryParams:(NSArray*)queryParameters {
    for (int i = 0; i < queryParameters.count; ++i) {
        NSArray *queryPair = [queryParameters[i] componentsSeparatedByString:@"="];
        
        // This means that the user tapped 'Cancel' in the webview
        if ([[queryPair firstObject] isEqualToString:@"error"]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        // Gets popup value which will be used to match up and grab the correct access token
        if ([[queryPair firstObject] isEqualToString:@"popup"]) {
            self.popupString = [queryPair lastObject];
        }
    
        // Lets us know that the user was successfully logged in and ready to grab the access token
        if ([[queryPair firstObject] isEqualToString:@"code"]) {
            // Shows loading screen once we know the user has been successfully logged in
            [[AMBUtilities sharedInstance] showLoadingScreenForView:self.webView];
            
            [[AMBNetworkManager sharedInstance] getLinkedInAccessTokenWithPopupValue:self.popupString success:^(NSString *accessToken) {
                [self.delegate userDidContinue];
            } failure:^(NSString *error) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

- (void)getLinkedInClientInfo {
    [[AMBNetworkManager sharedInstance] getCompanyUIDWithSuccess:^(NSString *companyUID) {
        [[AMBNetworkManager sharedInstance] getLinkedInClientValuesWithUID:companyUID success:^(NSDictionary *clientValues) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[AMBValues getLinkedInAuthorizationUrl]]]];
        } failure:^(NSString *error) {
            DLog(@"Unable to get client values - %@", error);
            [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"LinkedIn is currently unavailable" withUniqueID:@"linkedError" forViewController:self shouldDismissVCImmediately:NO];
        }];
    } failure:^(NSString *error) {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"LinkedIn is currently unavailable" withUniqueID:@"linkedError" forViewController:self shouldDismissVCImmediately:NO];
    }];
}

@end
