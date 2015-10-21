//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//


#import "AMBIdentify.h"
#import <UIKit/UIKit.h>
#import "AMBErrors.h"
@import WebKit;

@interface AMBIdentify () <WKNavigationDelegate>
//@property UIWebView *webview;
@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property WKWebView *webview;
@end

@implementation AMBIdentify

- (instancetype)init {
    if (self = [super init]) {
        self.webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];
        self.webview.navigationDelegate = self;
        self.webview.hidden = YES;
        self.fp = [[NSMutableDictionary alloc] init];
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.webview];
    }
    return self;
}



#pragma mark - Public API
- (void)identifyWithURL:(NSString *)url completion:(void (^)(NSMutableDictionary *resp, NSError *e))completion {
    self.completion = completion;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
}



#pragma mark -
- (void)extractVariable:(NSString *)var {
    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
    __weak AMBIdentify *weakSelf = self;
    [self.webview evaluateJavaScript:js completionHandler:^(id _Nullable result,  NSError * _Nullable  error) {
        NSString *dataStr = (NSString *)result;
        if (dataStr == nil) {
            [weakSelf triggerCompletion:nil error:AMBNOVALError()];
            return;
        }
        NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
        weakSelf.fp = returnVal;
        [weakSelf triggerCompletion:returnVal error:e];
    }];
}



#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([[navigationAction.request.URL absoluteString] isEqualToString:@"ambassador:ios/"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self extractVariable:@"augur.json"];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self triggerCompletion:nil error:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self triggerCompletion:nil error:error];
}



#pragma mark -
- (void)triggerCompletion:(NSMutableDictionary *)resp error:(NSError *)error {
    __weak AMBIdentify *weakSelf = self;
    if (weakSelf.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completion(resp, error);
        });
    }
}



#pragma mark -
+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid {
    NSString *baseUrl;
#if AMBPRODUCTION
    baseUrl = @"https://mbsy.co/universal/landing/?url=ambassador:ios/";
#else
    baseUrl = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios/";
#endif
    
    return [baseUrl stringByAppendingString:[NSString stringWithFormat:@"&universal_id=%@", uid]];
}

//#import "AMBIdentify.h"
//#import <UIKit/UIKit.h>
//#import "Pusher.h"
//#import "AMBUtilities.h"
//#import "AMBConstants.h"
//
//
//
//#pragma mark - Local Constants
//
//#if AMBPRODUCTION
//NSString * const AMB_IDENTIFY_URL = @"https://mbsy.co/universal/landing/?url=ambassador:ios/";
//#else
//NSString * const AMB_IDENTIFY_URL = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios/";
//#endif
//
//NSString * const AMB_IDENTIFY_JS_VAR = @"JSON.stringify(augur.json)";
//NSString * const AMB_IDENTIFY_SIGNAL_URL = @"ambassador";
//
//#if AMBPRODUCTION
//NSString * const AMB_IDENTIFY_SEND_URL = @"https://api.getambassador.com/universal/action/identify/";
//#else
//NSString * const AMB_IDENTIFY_SEND_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/";
//#endif
//
//
//float const AMB_IDENTIFY_RETRY_TIME = 2.0;
//NSString * const AMB_INSIGHTS_URL = @"https://api.augur.io/v2/user?key=***REMOVED***&uid=";
//
//NSString * const SEND_IDENTIFY_ENROLL_KEY = @"enroll";
//NSString * const SEND_IDENTIFY_CAMPAIGN_ID_KEY = @"campaign_id";
//NSString * const SEND_IDENTIFY_EMAIL_KEY = @"email";
//NSString * const SEND_IDENTIFY_FP_KEY = @"fp";
//NSString * const SEND_IDENTIFY_MBSY_SOURCE_KEY = @"mbsy_source";
//NSString * const SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY = @"mbsy_cookie_code";
//NSString * const SEND_IDENTIFY_SOURCE_KEY = @"source";
//
//NSString * const PUSHER_AUTH_AUTHTYPE_KEY = @"auth_type";
//NSString * const PUSHER_AUTH_CHANNEL_KEY = @"channel";
//NSString * const PUSHER_AUTH_SOCKET_ID_KEY = @"socket_id";
//#pragma mark -
//
//
//
//@interface AMBIdentify () <UIWebViewDelegate, AMBPTPusherDelegate>
//
//@property UIWebView *webview;
//@property UIView *view;
//@property AMBPTPusher *client;
//@property AMBPTPusherPrivateChannel *channel;
//
//@end
//
//
//
//@implementation AMBIdentify
//
//#pragma mark - Object lifecycle
//- (id)initForFullIdentify
//{
//    DLog();
//    if ([super init])
//    {
//        self.webview = [[UIWebView alloc] init];
//        self.webview.delegate = self;
//        self.client = [AMBPTPusher pusherWithKey:AMB_PUSHER_KEY delegate:self encrypted:YES];
//        self.client.authorizationURL = [NSURL URLWithString:AMB_PUSHER_AUTHENTICATION_URL];
//        [self.client connect];
//    }
//    
//    return self;
//}
//
//- (void)identify
//{
//    DLog();
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&universal_id=%@",AMB_IDENTIFY_URL,
//                                       [[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_ID_DEFAULTS_KEY]]];
//    DLog(@"%@", [url absoluteString]);
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webview loadRequest:request];
//}
//
//- (void)identifyWithEmail:(NSString *)email
//{
//    DLog();
//    [[NSUserDefaults standardUserDefaults] setValue:email forKey:AMB_USER_EMAIL_DEFAULTS_KEY];
//    [self identify];
//}
//
//
//
//#pragma mark - Augur callback
//- (BOOL)getIdentifyData
//{
//    DLog();
//    
//    // Pull the data from the webview
//    DLog(@"Grabbing the identify data string from webView");
//    NSString *identifyDataString = [self.webview stringByEvaluatingJavaScriptFromString:AMB_IDENTIFY_JS_VAR];
//    NSData *identifyDataRaw = [identifyDataString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    __autoreleasing NSError *e;
//    DLog(@"Attempt to serialize identify data NSData object into Dictionary");
//    NSMutableDictionary *identifyData = [NSJSONSerialization JSONObjectWithData:identifyDataRaw options:0 error:&e];
//    
//    if (e)
//    {
//        DLog(@"Error parsing identify data NSData object: %@", e.debugDescription);
//        
//        // Try again
//        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
//        return NO;
//    }
//    else
//    {
//        DLog(@"Identify data NSData object was serialized. Data: %@", identifyData);
//        self.identifyData = [NSMutableDictionary dictionaryWithDictionary:identifyData];
//        
//        // Save a copy locally
//        [[NSUserDefaults standardUserDefaults] setObject:identifyData
//                                                  forKey:AMB_IDENTIFY_USER_DEFAULTS_KEY];
//        
//        
//        // Send identify to backend if there is an email
//        if (![[[NSUserDefaults standardUserDefaults] valueForKey:AMB_USER_EMAIL_DEFAULTS_KEY] isEqualToString:@""])
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!self.channel) {
//                    self.channel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"snippet-channel@user=%@", self.identifyData[@"device"][@"ID"]]];
//                    [self.channel bindToEventNamed:@"identify_action" handleWithBlock:^(AMBPTPusherEvent *event)
//                     {
//                         NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:event.data];
//                         
//                         if ([[dictionary allKeys] containsObject:@"url"]) {
//                             [self getPusherPayloadFromURL:[dictionary valueForKey:@"url"]];
//                         } else {
//                             [self savePusherDataFromDictionary:dictionary];
//                         }
//                     }];
//                }
//            });
//        }
//        
//        // Get insights data
//        [self getInsightsDataForUID:self.identifyData[@"consumer"][@"UID"] success:nil fail:nil];
//        
//        return YES;
//    }
//}
//
//- (void)getInsightsDataForUID:(NSString *)UID success:(void (^)(NSMutableDictionary *response))success fail:(void (^)(NSError *error))fail
//{
//    DLog();
//    
//    // Check if we have a UID (Fingerprints don't always have them)
//    if ([UID isEqualToString:@""])
//    {
//        DLog(@"No UID exists - creating emtpy Insights dictionary");
//        
//        // Create an emtpy Insights dictionary and save
//        NSDictionary *insights = @{
//                                   @"PSYCHOGRAPHICS": @{},
//                                   @"DEMOGRAPHICS":@{},
//                                   @"GEOGRAPHICS": @{},
//                                   @"PROFILES":@{},
//                                   @"PRIVATE":@{},
//                                   @"MISC":@{}
//                                   };
//        [[NSUserDefaults standardUserDefaults] setObject:insights
//                                                  forKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
//        if (success) {
//            success([NSMutableDictionary dictionaryWithDictionary:insights]);
//        }
//        return;
//    }
//    
//    // There is a UID and we can make a request to Augur's insights API
//    NSString *urlString = [NSString stringWithFormat:@"%@%@", AMB_INSIGHTS_URL, UID];
//    
//    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
//                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//      {
//          DLog();
//          if (!error)
//          {
//              // Check for valid response code
//              DLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode)
//              if (((NSHTTPURLResponse *)response).statusCode == 200 ||
//                  ((NSHTTPURLResponse *)response).statusCode == 202)
//              {
//                  __autoreleasing NSError *e = nil;
//                  NSMutableDictionary *insightsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
//                  
//                  if (!e)
//                  {
//                      // Save a copy locally
//                      [[NSUserDefaults standardUserDefaults] setObject:insightsData
//                                                                forKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
//                      DLog(@"%@", insightsData);
//                      __autoreleasing NSError *err;
//                      NSMutableDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
//                      if (err) {
//                          if (fail) {
//                              fail(err);
//                          }
//                      } else {
//                          if (success) {
//                              success(responseJSON);
//                          }
//                      }
//                  }
//                  else
//                  {
//                      DLog(@"Error serializing insights data - %@", e.localizedDescription);
//                      if (fail) {
//                          fail(e);
//                      }
//                  }
//              }
//              else
//              {
//                  DLog(@"Insights network call returned status code - %ld", (long)((NSHTTPURLResponse *)response).statusCode);
//                  if (fail) {
//                      fail([NSError errorWithDomain:@"AmbassadorErrorDomain" code:(long)((NSHTTPURLResponse *)response).statusCode userInfo:nil]);
//                  }
//              }
//          }
//          else
//          {
//              DLog(@"Error making insights call - %@", error.localizedDescription);
//              if (fail) {
//                  fail(error);
//              }
//          }
//      }] resume];
//}
//
//- (void)sendIdentifyData
//{
//    DLog(@"Preparig to send Identify data");
//    
//    NSDictionary *fpDictionary = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_USER_DEFAULTS_KEY]) ? [[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_USER_DEFAULTS_KEY] : @{};
//    
//    NSString *campId = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY]) ?
//        [[NSUserDefaults standardUserDefaults] objectForKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY] : @"";
//    
//    NSString *emailString = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_USER_EMAIL_DEFAULTS_KEY]) ? [[NSUserDefaults standardUserDefaults] objectForKey:AMB_USER_EMAIL_DEFAULTS_KEY] : @"";
//    
//    // Create the payload to send
//    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{
//                                                                                   SEND_IDENTIFY_ENROLL_KEY: @YES,
//                                                                                   SEND_IDENTIFY_CAMPAIGN_ID_KEY:campId,
//                                                                                   SEND_IDENTIFY_EMAIL_KEY : emailString,
//                                                                                   SEND_IDENTIFY_FP_KEY: fpDictionary,
//                                                                                   SEND_IDENTIFY_MBSY_SOURCE_KEY : @"",
//                                                                                   SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY : @"",
//                                                                                   SEND_IDENTIFY_SOURCE_KEY : @"ios_sdk_pilot"
//                                                                                   }];
//    
//    DLog(@"%@", payload);
//    //Create the POST request
//    NSURL *url = [NSURL URLWithString:AMB_IDENTIFY_SEND_URL];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY] forHTTPHeaderField:@"Authorization"];
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
//    
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
//                                  dataTaskWithRequest:request
//                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//      {
//          if (!error)
//          {
//              DLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
//              
//              //Check for 2xx status codes
//              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
//                  ((NSHTTPURLResponse *)response).statusCode < 300)
//              {
//                  // Looking for a "Polling" response
//                  DLog(@"Response from backend from sending identify (looking for 'polling'): %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
//              }
//              else if (((NSHTTPURLResponse *)response).statusCode == 401)
//              {
//                  NSLog(@"AMBASSADOR ERROR: Unauthorized access encountered. Check the API Key provided.");
//              }
//          }
//          else
//          {
//              DLog(@"Error: %@", error.localizedDescription);
//          }
//      }];
//    [task resume];
//}
//
//
//
//#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    DLog();
//    
//    // Parse the URL string delimiting at ":"
//    NSString *urlRequestString = [[request URL] absoluteString];
//    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
//    DLog(@"Url components: %@", urlRequestComponents);
//    
//    // Check if the URL is signal URL used in Augur javascript callback
//    if (urlRequestComponents.count > 1 &&
//        [(NSString *)urlRequestComponents[0] isEqualToString:AMB_IDENTIFY_SIGNAL_URL])
//    {
//        DLog(@"Found the signal url. Component found: %@", urlRequestComponents[0]);
//        [self getIdentifyData];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    DLog();
//    
//    // Get the response code
//    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
//    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
//    response = (NSHTTPURLResponse *)cachedResponse.response;
//    
//    // Check for a vaild response code
//    DLog(@"Response code: %ld", (long)response.statusCode);
//    if (!(response.statusCode == 200 || response.statusCode == 202))
//    {
//        DLog(@"Trying to identify again after %f seconds", AMB_IDENTIFY_RETRY_TIME);
//        [self performSelector:@selector(identify)
//                   withObject:self
//                   afterDelay:AMB_IDENTIFY_RETRY_TIME]; // Try again
//    }
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    DLog(@"The error was: %@", error);
//    DLog(@"Trying to identify again after %f seconds", AMB_IDENTIFY_RETRY_TIME);
//    
//    // Schedule another call to identify
//    [self performSelector:@selector(identify)
//               withObject:self
//               afterDelay:AMB_IDENTIFY_RETRY_TIME];
//}
//
//
//
//#pragma mark - PTPusherDelegate
//- (void)pusher:(AMBPTPusher *)pusher willAuthorizeChannel:(AMBPTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
//{
//    DLog(@"Channel: %@\nRequest body: %@", channel.name, [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding]);
//    
//    // Modify the default autheticate request that Pusher will make. The
//    // HTTP body is set per Ambassador back end requirements
//    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY] forHTTPHeaderField:@"Authorization"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSMutableString *httpBodyString = [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding];
//    NSMutableDictionary *httpBody = AMBparseQueryString(httpBodyString);
//    
//    // Create the body dectionary
//    httpBody = [NSMutableDictionary dictionaryWithDictionary:@{
//                                                               PUSHER_AUTH_AUTHTYPE_KEY : @"private",
//                                                               PUSHER_AUTH_CHANNEL_KEY : channel.name,
//                                                               PUSHER_AUTH_SOCKET_ID_KEY : httpBody[PUSHER_AUTH_SOCKET_ID_KEY]
//                                                               }];
//    
//    // Turn into NSData to attatch to the request's HTTPBody
//    __autoreleasing NSError *e = nil;
//    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:&e];
//    if (!e)
//    {
//        request.HTTPBody = bodyData;
//    }
//    else
//    {
//        DLog(@"Error serializing pusher channel subscription request's HTTPBody - %@", e.description);
//    }
//}
//
//- (void)pusher:(AMBPTPusher *)pusher didFailToSubscribeToChannel:(AMBPTPusherChannel *)channel withError:(NSError *)error
//{
//    DLog(@"%@ - %@",channel.name, error.debugDescription);
//}
//
//- (void)pusher:(AMBPTPusher *)pusher didSubscribeToChannel:(AMBPTPusherChannel *)channel
//{
//    DLog(@"Subscribed to: %@", channel.name);
//}
//
//#pragma mark - Pusher url call
//
//- (void)getPusherPayloadFromURL:(NSString*)urlString {
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSMutableURLRequest *pusherRequest = [NSMutableURLRequest requestWithURL:url];
//    
//    pusherRequest.HTTPMethod = @"GET";
//    [pusherRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [pusherRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY] forHTTPHeaderField:@"Authorization"];
//    
//    NSURLSessionDataTask *pusherSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
//                                                                    delegate:nil
//                                                                    delegateQueue:[NSOperationQueue mainQueue]]
//    dataTaskWithRequest:pusherRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (((NSHTTPURLResponse *)response).statusCode >= 200 && ((NSHTTPURLResponse *)response).statusCode < 300) {
//            DLog(@"External call to Pusher URL successful!");
//            NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            [self savePusherDataFromDictionary:dictionary];
//        } else {
//            DLog(@"There was an error getting Pusher data from %@", urlString);
//        }
//    }];
//    
//    [pusherSession resume];
//}
//
//- (void)savePusherDataFromDictionary:(NSMutableDictionary*)dictionary {
//    NSString *phone = dictionary[@"phone"];
//    NSString *firstName = dictionary[@"first_name"];
//    NSString *lastName = dictionary[@"last_name"];
//    if ([phone isEqual:[NSNull null]]) {
//        dictionary[@"phone"] = @"";
//    }
//    
//    if ([firstName isEqual:[NSNull null]]) {
//        dictionary[@"first_name"] = @"";
//    }
//    
//    if ([lastName isEqual:[NSNull null]]) {
//        dictionary[@"last_name"] = @"";
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
//    [self.delegate ambassadorDataWasRecieved:dictionary];
//}

@end
