//
//  LinkedInAuthorizeWebView.m
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "LinkedInAuthorizeWebView.h"
#import "Utilities.h"
#import "Constants.h"



#pragma mark - Local Constants
NSString * const TITLE = @"Authorize LinkedIn";
NSString * const AUTHORIZE_URL = @"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=***REMOVED***&redirect_uri=http://localhost:2999/&state=987654321&scope=r_basicprofile%20w_share";
NSString * const LINKEDIN_CALLBACK_URL = @"http://localhost:2999/";
NSString * const REQUEST_TOKEN_URL = @"https://www.linkedin.com/uas/oauth2/accessToken";


NSString* buildRequestTokenHTTPBody(NSString* key)
{
    return [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=http://localhost:2999/&client_id=***REMOVED***&client_secret=***REMOVED***", key];
}
#pragma mark -



@interface LinkedInAuthorizeWebView () <UIWebViewDelegate>

@property UIWebView *webView;

@end



@implementation LinkedInAuthorizeWebView

- (void)viewDidLoad {
    DLog();
    [super viewDidLoad];
    
    self.navigationItem.title = TITLE;
    UIButton *backButton = [[UIButton alloc] initWithFrame:AMB_CLOSE_BUTTON_FRAME()];
    [backButton setImage:imageFromBundleNamed(AMB_BACK_BUTTON_NAME) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    NSString * addressString = AUTHORIZE_URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:addressString]]];
    [self.view addSubview:self.webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog();
    //Parse the URL string delimiting at ":"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@"?"];
    if ([[urlRequestComponents firstObject] isEqualToString:LINKEDIN_CALLBACK_URL])
    {
        DLog();
        self.webView.hidden = YES;
        if (urlRequestComponents.count > 1)
        {
            NSArray *queryParameters = [urlRequestComponents[1] componentsSeparatedByString:@"&"];
            for (int i = 0; i < queryParameters.count; ++i)
            {
                NSArray *queryPair = [queryParameters[i] componentsSeparatedByString:@"="];
                if ([[queryPair firstObject] isEqualToString:LINKEDIN_ERROR_KEY])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                if ([[queryPair firstObject] isEqualToString:LINKEDIN_CODE_KEY])
                {
                    DLog(@"Recieved client auth code");
                    [self getRequestTokenWithKey:[NSString stringWithString:[queryPair lastObject]]];
                }
            }
        }
        return NO;
    }
    return YES;
}

- (void)getRequestTokenWithKey:(NSString *)key
{
    DLog();
    NSURL *url = [NSURL URLWithString:REQUEST_TOKEN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *body = buildRequestTokenHTTPBody(key);
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
    {
          DLog();
          if (!error)
          {
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  NSMutableDictionary *tokenResponse = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                  
                  int offset = [(NSNumber *)tokenResponse[LINKEDIN_EXPIRES_KEY] intValue];
                  NSDate * date = [NSDate dateWithTimeIntervalSinceNow:offset - 1000];
                  tokenResponse[LINKEDIN_EXPIRES_KEY] = date;
                  
                  DLog(@"Recieved new auth token");
                  [[NSUserDefaults standardUserDefaults] setObject:tokenResponse forKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
                  dispatch_async(dispatch_get_main_queue(),
                  ^{
                      DLog(@"***************************");
                      [self.delegate userDidContinue];
                      DLog(@"%@", self);
                  });
              }
          }
          else
          {
              DLog(@"Error: %@", error.localizedDescription);
          }
    }];
    [task resume];
}

- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
