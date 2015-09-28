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

@interface AMBIdentify () <UIWebViewDelegate>
@property UIWebView *webview;
@property UIView *view;
@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@end

@implementation AMBIdentify

#pragma mark - Initialization
- (id)init {
    if ([super init]) {
        self.webview = [[UIWebView alloc] init];
        self.webview.delegate = self;
    }
    return self;
}


<<<<<<< HEAD
#pragma mark - Public API
- (void)identifyWithURL:(NSString *)url completion:(void (^)(NSMutableDictionary *resp, NSError *e))completion {
    self.completion = completion;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
=======

#pragma mark - Augur callback
- (BOOL)getIdentifyData
{
    DLog();
    
    // Pull the data from the webview
    DLog(@"Grabbing the identify data string from webView");
    NSString *identifyDataString = [self.webview stringByEvaluatingJavaScriptFromString:AMB_IDENTIFY_JS_VAR];
    NSData *identifyDataRaw = [identifyDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    __autoreleasing NSError *e;
    DLog(@"Attempt to serialize identify data NSData object into Dictionary");
    NSMutableDictionary *identifyData = [NSJSONSerialization JSONObjectWithData:identifyDataRaw options:0 error:&e];
    
    if (e)
    {
        DLog(@"Error parsing identify data NSData object: %@", e.debugDescription);
        
        // Try again
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
        return NO;
    }
    else
    {
        DLog(@"Identify data NSData object was serialized. Data: %@", identifyData);
        self.identifyData = [NSMutableDictionary dictionaryWithDictionary:identifyData];
        
        // Save a copy locally
        [[NSUserDefaults standardUserDefaults] setObject:identifyData
                                                  forKey:AMB_IDENTIFY_USER_DEFAULTS_KEY];
        
        
        // Send identify to backend if there is an email
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:AMB_USER_EMAIL_DEFAULTS_KEY] isEqualToString:@""])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.channel) {
                    self.channel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"snippet-channel@user=%@", self.identifyData[@"device"][@"ID"]]];
                    [self.channel bindToEventNamed:@"identify_action" handleWithBlock:^(AMBPTPusherEvent *event)
                     {
                         NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:event.data];
                         
                         if ([[dictionary allKeys] containsObject:@"url"]) {
                             [self getPusherPayloadFromURL:[dictionary valueForKey:@"url"]];
                         } else {
                             [self savePusherDataFromDictionary:dictionary];
                         }
                     }];
                    [self sendIdentifyData];
                }
            });
        }
        
        // Get insights data
        [self getInsightsDataForUID:self.identifyData[@"consumer"][@"UID"] success:nil fail:nil];
        
        return YES;
    }
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
}


<<<<<<< HEAD
#pragma mark -
- (void)extractVariable:(NSString *)var {
    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
    NSString *dataStr = [self.webview stringByEvaluatingJavaScriptFromString:js];
    NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
    self.fp = returnVal;
    [self triggerCompletion:returnVal error:e];
=======
- (void)sendIdentifyData
{
    DLog(@"Preparig to send Identify data");
    
    NSDictionary *fpDictionary = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_USER_DEFAULTS_KEY]) ? [[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_USER_DEFAULTS_KEY] : @{};
    
    NSString *campId = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY]) ?
        [[NSUserDefaults standardUserDefaults] objectForKey:AMB_CAMPAIGN_ID_DEFAULTS_KEY] : @"";
    
    NSString *emailString = ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_USER_EMAIL_DEFAULTS_KEY]) ? [[NSUserDefaults standardUserDefaults] objectForKey:AMB_USER_EMAIL_DEFAULTS_KEY] : @"";
    
    // Create the payload to send
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   SEND_IDENTIFY_ENROLL_KEY: @YES,
                                                                                   SEND_IDENTIFY_CAMPAIGN_ID_KEY:campId,
                                                                                   SEND_IDENTIFY_EMAIL_KEY : emailString,
                                                                                   SEND_IDENTIFY_FP_KEY: fpDictionary,
                                                                                   SEND_IDENTIFY_MBSY_SOURCE_KEY : @"",
                                                                                   SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY : @"",
                                                                                   SEND_IDENTIFY_SOURCE_KEY : @"ios_sdk_pilot"
                                                                                   }];
    
    DLog(@"%@", payload);
    //Create the POST request
    NSURL *url = [NSURL URLWithString:AMB_IDENTIFY_SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY] forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              DLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  // Looking for a "Polling" response
                  DLog(@"Response from backend from sending identify (looking for 'polling'): %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
              }
              else if (((NSHTTPURLResponse *)response).statusCode == 401)
              {
                  NSLog(@"AMBASSADOR ERROR: Unauthorized access encountered. Check the API Key provided.");
              }
          }
          else
          {
              DLog(@"Error: %@", error.localizedDescription);
          }
      }];
    [task resume];
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *reqStr = [[request URL] absoluteString];
    NSArray *reqStrComponents = [reqStr componentsSeparatedByString:@":"];
    if (reqStrComponents.count > 1 && [(NSString *)reqStrComponents[0] isEqualToString:@"ambassador"]) {
        [self extractVariable:@"augur.json"];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        [self triggerCompletion:nil error:AMBBADRESPError(response.statusCode, response)];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self triggerCompletion:nil error:error];
}

- (void)triggerCompletion:(NSMutableDictionary *)resp error:(NSError *)error {
    __weak AMBIdentify *weakSelf = self;
    if (weakSelf.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completion(resp, error);
        });
    }
}

<<<<<<< HEAD
=======
- (void)pusher:(AMBPTPusher *)pusher didFailToSubscribeToChannel:(AMBPTPusherChannel *)channel withError:(NSError *)error
{
    DLog(@"%@ - %@",channel.name, error.debugDescription);
}

- (void)pusher:(AMBPTPusher *)pusher didSubscribeToChannel:(AMBPTPusherChannel *)channel
{
    DLog(@"Subscribed to: %@", channel.name);
}

#pragma mark - Pusher url call

- (void)getPusherPayloadFromURL:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *pusherRequest = [NSMutableURLRequest requestWithURL:url];
    
    pusherRequest.HTTPMethod = @"GET";
    [pusherRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [pusherRequest setValue:[[NSUserDefaults standardUserDefaults] valueForKey:AMB_UNIVERSAL_TOKEN_DEFAULTS_KEY] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *pusherSession = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                    delegate:nil
                                                                    delegateQueue:[NSOperationQueue mainQueue]]
    dataTaskWithRequest:pusherRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (((NSHTTPURLResponse *)response).statusCode >= 200 && ((NSHTTPURLResponse *)response).statusCode < 300) {
            DLog(@"External call to Pusher URL successful!");
            NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self savePusherDataFromDictionary:dictionary];
        } else {
            DLog(@"There was an error getting Pusher data from %@", urlString);
        }
    }];
    
    [pusherSession resume];
}

- (void)savePusherDataFromDictionary:(NSMutableDictionary*)dictionary {
    NSString *phone = dictionary[@"phone"];
    NSString *firstName = dictionary[@"first_name"];
    NSString *lastName = dictionary[@"last_name"];
    if ([phone isEqual:[NSNull null]]) {
        dictionary[@"phone"] = @"";
    }
    
    if ([firstName isEqual:[NSNull null]]) {
        dictionary[@"first_name"] = @"";
    }
    
    if ([lastName isEqual:[NSNull null]]) {
        dictionary[@"last_name"] = @"";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
    [self.delegate ambassadorDataWasRecieved:dictionary];
}

>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
@end
