//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Identify.h"
#import <UIKit/UIKit.h>
#import <Pusher.h>
#import "Utilities.h"
#import "Constants.h"



#pragma mark - Local Constants
NSString * const AMB_IDENTIFY_URL = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios/&universal_id=abfd1c89-4379-44e2-8361-ee7b87332e32";
NSString * const AMB_IDENTIFY_JS_VAR = @"JSON.stringify(augur_data)";
NSString * const AMB_IDENTIFY_SIGNAL_URL = @"ambassador";
NSString * const AMB_IDENTIFY_SEND_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/?u=abfd1c89-4379-44e2-8361-ee7b87332e32";
float const AMB_IDENTIFY_RETRY_TIME = 2.0;
NSString * const AMB_INSIGHTS_URL = @"https://api.augur.io/v2/user?key=7g1a8dumog40o61y5irl1sscm4nu6g60&uid=";

NSString * const SEND_IDENTIFY_EMAIL_KEY = @"email";
NSString * const SEND_IDENTIFY_FP_KEY = @"fp";
NSString * const SEND_IDENTIFY_MBSY_SOURCE_KEY = @"mbsy_source";
NSString * const SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY = @"mbsy_cookie_code";

NSString * const PUSHER_AUTH_AUTHTYPE_KEY = @"auth_type";
NSString * const PUSHER_AUTH_CHANNEL_KEY = @"channel";
NSString * const PUSHER_AUTH_SOCKET_ID_KEY = @"socket_id";
#pragma mark -



@interface Identify () <UIWebViewDelegate, PTPusherDelegate>

@property UIWebView *webview;
@property UIView *view;
@property NSString *email;
@property PTPusher *client;
@property PTPusherPrivateChannel *channel;
@property NSString *APIKey;

@end



@implementation Identify

#pragma mark - Object lifecycle
- (id)initWithKey:(NSString *)key
{
    DLog();
    if ([super init])
    {
        self.webview = [[UIWebView alloc] init];
        self.webview.delegate = self;
        self.email = @"";
        self.APIKey = key;
        self.client = [PTPusher pusherWithKey:AMB_PUSHER_KEY delegate:self encrypted:YES];
        self.client.authorizationURL = [NSURL URLWithString:AMB_PUSHER_AUTHENTICATION_URL];
        [self.client connect];
    }
    
    return self;
}

- (void)identify
{
    DLog();
    NSURL *url = [NSURL URLWithString:AMB_IDENTIFY_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (void)identifyWithEmail:(NSString *)email
{
    DLog();
    self.email = email;
    [self identify];
}



#pragma mark - Augur callback
- (BOOL)getIdentifyData
{
    DLog();
    
    // Pull the data from the webview
    DLog(@"Grabbing the identify data string from webView");
    NSString *identifyDataString = [self.webview stringByEvaluatingJavaScriptFromString:AMB_IDENTIFY_JS_VAR];
    DLog(@"Converting identify data string to NSData *************************%@", identifyDataString);
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
        
        // Call the delegate method
        [self.delegate identifyDataWasRecieved:identifyData];
        
        // Send identify to backend if there is an email
        if (![self.email isEqualToString:@""])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.channel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"snippet-channel@user=%@", self.identifyData[@"device"][@"ID"]]];
                [self.channel bindToEventNamed:@"identify_action" handleWithBlock:^(PTPusherEvent *event)
                 {
                     [[NSUserDefaults standardUserDefaults] setValue:event.data forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
                     DLog(@"Pusher event - %@", event.data);
                 }];
                [self sendIdentifyData];
            });
        }
        
        // Get insights data
        [self getInsightsDataForUID:self.identifyData[@"consumer"][@"UID"]];
        
        return YES;
    }
}

- (void)getInsightsDataForUID:(NSString *)UID
{
    DLog();
    
    // Check if we have a UID (Fingerprints don't always have them)
    if ([UID isEqualToString:@""])
    {
        DLog(@"No UID exists - creating emtpy Insights dictionary");
        
        // Create an emtpy Insights dictionary and save
        NSDictionary *insights = @{
                                   @"PSYCHOGRAPHICS": @{},
                                   @"DEMOGRAPHICS":@{},
                                   @"GEOGRAPHICS": @{},
                                   @"PROFILES":@{},
                                   @"PRIVATE":@{},
                                   @"MISC":@{}
                                   };
        [[NSUserDefaults standardUserDefaults] setObject:insights
                                                  forKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
        return;
    }
    
    // There is a UID and we can make a request to Augur's insights API
    NSString *urlString = [NSString stringWithFormat:@"%@%@", AMB_INSIGHTS_URL, UID];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          DLog();
          if (!error)
          {
              // Check for valid response code
              DLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode)
              if (((NSHTTPURLResponse *)response).statusCode == 200 ||
                  ((NSHTTPURLResponse *)response).statusCode == 202)
              {
                  __autoreleasing NSError *e = nil;
                  NSMutableDictionary *insightsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
                  
                  if (!e)
                  {
                      // Save a copy locally
                      [[NSUserDefaults standardUserDefaults] setObject:insightsData
                                                                forKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
                      DLog(@"%@", insightsData);
                      
                      // Call the delegate
                      [self.delegate insightsDataWasRecieved:insightsData];
                  }
                  else
                  {
                      DLog(@"Error serializing insights data - %@", e.localizedDescription);
                  }
              }
              else
              {
                  DLog(@"Insights network call returned status code - %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              }
          }
          else
          {
              DLog(@"Error making insights call - %@", error.localizedDescription);
          }
      }] resume];
}

- (void)sendIdentifyData
{
    DLog(@"Preparig to send Identify data");
    
    // Create the payload to send
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   SEND_IDENTIFY_EMAIL_KEY : self.email,
                                                                                   SEND_IDENTIFY_FP_KEY: self.identifyData,
                                                                                   SEND_IDENTIFY_MBSY_SOURCE_KEY : @"",
                                                                                   SEND_IDENTIFY_MBSY_COOKIE_CODE_KEY : @""
                                                                                   }];
    
    //Create the POST request
    NSURL *url = [NSURL URLWithString:AMB_IDENTIFY_SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:self.APIKey forHTTPHeaderField:@"Authorization"];
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
                                              DLog(@"Response from backend from sending identify: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                                          }
                                      }
                                      else
                                      {
                                          DLog(@"Error: %@", error.localizedDescription);
                                      }
                                  }];
    [task resume];
}



#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog();
    
    // Parse the URL string delimiting at ":"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
    DLog(@"Url components: %@", urlRequestComponents);
    
    // Check if the URL is signal URL used in Augur javascript callback
    if (urlRequestComponents.count > 1 &&
        [(NSString *)urlRequestComponents[0] isEqualToString:AMB_IDENTIFY_SIGNAL_URL])
    {
        DLog(@"Found the signal url. Component found: %@", urlRequestComponents[0]);
        [self getIdentifyData];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog();
    
    // Get the response code
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    
    // Check for a vaild response code
    DLog(@"Response code: %ld", (long)response.statusCode);
    if (!(response.statusCode == 200 || response.statusCode == 202))
    {
        DLog(@"Trying to identify again after %f seconds", AMB_IDENTIFY_RETRY_TIME);
        [self performSelector:@selector(identify)
                   withObject:self
                   afterDelay:AMB_IDENTIFY_RETRY_TIME]; // Try again
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"The error was: %@", error);
    DLog(@"Trying to identify again after %f seconds", AMB_IDENTIFY_RETRY_TIME);
    
    // Schedule another call to identify
    [self performSelector:@selector(identify)
               withObject:self
               afterDelay:AMB_IDENTIFY_RETRY_TIME];
}



#pragma mark - PTPusherDelegate
- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
{
    DLog(@"Channel: %@\nRequest body: %@", channel.name, [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding]);
    
    // Modify the default autheticate request that Pusher will make. The
    // HTTP body is set per Ambassador back end requirements
    [request setValue:self.APIKey forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *httpBodyString = [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding];
    NSMutableDictionary *httpBody = parseQueryString(httpBodyString);
    
    // Create the body dectionary
    httpBody = [NSMutableDictionary dictionaryWithDictionary:@{
                                                               PUSHER_AUTH_AUTHTYPE_KEY : @"private",
                                                               PUSHER_AUTH_CHANNEL_KEY : channel.name,
                                                               PUSHER_AUTH_SOCKET_ID_KEY : httpBody[PUSHER_AUTH_SOCKET_ID_KEY]
                                                               }];
    
    // Turn into NSData to attatch to the request's HTTPBody
    __autoreleasing NSError *e = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:&e];
    if (!e)
    {
        request.HTTPBody = bodyData;
    }
    else
    {
        DLog(@"Error serializing pusher channel subscription request's HTTPBody - %@", e.description);
    }
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    DLog(@"%@ - %@",channel.name, error.debugDescription);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    DLog(@"Subscribed to: %@", channel.name);
}

@end
