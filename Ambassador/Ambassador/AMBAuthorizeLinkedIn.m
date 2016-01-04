//
//  AuthorizeLinkedIn.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBAuthorizeLinkedIn.h"
#import "AMBLinkedInAPIConstants.h"
#import "AMBConstants.h"


@interface AMBAuthorizeLinkedIn () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AMBAuthorizeLinkedIn

#pragma mark - Local Constants
NSString * const TITLE = @"Authorize LinkedIn";
//NSString * const AMB_LINKEDIN_USER_DEFAULTS_KEY = @"AMBLINKEDINSTORAGE";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TITLE;
    self.webView.delegate = self;
    NSString * addressString = AMB_LKDN_AUTH_URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:addressString]]];
    [self.view addSubview:self.webView];
    [[AMBUtilities sharedInstance] showLoadingScreenForView:self.view];
    
//    UIBarButtonItemleftBarButtonItem *blankBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
//    self.navigationItem. = blankBackButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //Parse the URL string delimiting at "?"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@"?"];
    if ([[urlRequestComponents firstObject] isEqualToString:AMB_LKDN_AUTH_CALLBACK_URL])
    {
        self.webView.hidden = YES;
        if (urlRequestComponents.count > 1)
        {
            NSArray *queryParameters = [urlRequestComponents[1] componentsSeparatedByString:@"&"];
            for (int i = 0; i < queryParameters.count; ++i)
            {
                NSArray *queryPair = [queryParameters[i] componentsSeparatedByString:@"="];
                if ([[queryPair firstObject] isEqualToString:AMB_LKDN_ERROR_DICT_KEY])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                if ([[queryPair firstObject] isEqualToString:AMB_LKDN_CODE_DICT_KEY])
                {
                    [self getRequestTokenWithKey:[NSString stringWithString:[queryPair lastObject]]];
                }
            }
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        [[AMBUtilities sharedInstance] hideLoadingView];
    }
}

- (void)getRequestTokenWithKey:(NSString *)key
{
    NSURL *url = [NSURL URLWithString:AMB_LKDN_REQUEST_OAUTH_TOKEN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *body = AMBlkdnBuildRequestTokenHTTPBody(key);
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  NSMutableDictionary *tokenResponse = [NSMutableDictionary
                                                        dictionaryWithDictionary:[NSJSONSerialization
                                                                                  JSONObjectWithData:data
                                                                                  options:0
                                                                                  error:nil]];
                  
                  int offset = [(NSNumber *)tokenResponse[AMB_LKDN_EXPIRES_DICT_KEY] intValue];
                  NSDate * date = [NSDate dateWithTimeIntervalSinceNow:offset - 1000];
                  tokenResponse[AMB_LKDN_EXPIRES_DICT_KEY] = date;
                  
                  [AMBValues setLinkedInExpirationDate:tokenResponse[@"expires_in"]];
                  [AMBValues setLinkedInAccessToken:tokenResponse[@"access_token"]];
                  [[NSUserDefaults standardUserDefaults] setObject:tokenResponse
                                                            forKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
                  dispatch_async(dispatch_get_main_queue(),
                                 ^{
                                     [self.delegate userDidContinue];
                                 });
              }
          }
          else
          {
              //TODO:Log the error
          }
      }];
    [task resume];
}

- (void)checkForInvalidatedTokenWithCompletion:(void(^)())complete {
    NSDictionary *authKey = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
    NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/v1/people/~?format=json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authKey[AMB_LKDN_OAUTH_TOKEN_KEY]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (((NSHTTPURLResponse*)response).statusCode == 401) {
                DLog(@"Nullifying Linkedin Tokens");
                [AMBValues setLinkedInAccessToken:nil];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            } else {
                DLog(@"LinkedIn Tokens are still up to date");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            }
        }
    }];
    [task resume];
}

@end
