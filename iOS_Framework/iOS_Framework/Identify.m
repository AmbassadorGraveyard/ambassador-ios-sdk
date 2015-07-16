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
NSString * const AMB_IDENTIFY_URL = @"http://127.0.0.1:7999/augur.html?cbURL=ambassador:mylocation";
NSString * const AMB_IDENTIFY_JS_VAR = @"JSONdata";
NSString * const AMB_IDENTIFY_SIGNAL_URL = @"ambassador";
NSString * const AMB_IDENTIFY_SEND_URL = @"https://dev-ambassador-api.herokuapp.com/universal/action/identify/?u=abfd1c89-4379-44e2-8361-ee7b87332e32";
float const AMB_IDENTIFY_RETRY_TIME = 2.0;
NSString * const AMB_INSIGHTS_URL = @"https://api.augur.io/v2/user?key=7g1a8dumog40o61y5irl1sscm4nu6g60&uid=";



@interface Identify () <UIWebViewDelegate, PTPusherDelegate>

@property UIWebView *webview;
@property UIView *view;
@property NSString *email;

//TODO: Declare pusher properties
@property PTPusher *client;
@property PTPusherPrivateChannel *channel;

@end



@implementation Identify

#pragma mark - Object lifecycle
- (id)init
{
    DLog();
    if ([super init])
    {
        self.webview = [[UIWebView alloc] init];
        self.webview.delegate = self;
        self.email = @"";
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
    DLog(@"Converting identify data string to NSData");
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
            self.channel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"snippet-channel@user=%@", self.identifyData[@"device"][@"ID"]]];
            [self.channel bindToEventNamed:@"identify_action" handleWithBlock:^(PTPusherEvent *event)
             {
                 [[NSUserDefaults standardUserDefaults] setValue:event.data forKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
                 NSLog(@"Pusher event - %@", event.data);
             }];
            [self sendIdentifyData];
        }
        
        // Get insights data
        [self getInsightsDataForUID:self.identifyData[@"consumer"][@"UID"]];
        
        return YES;
    }
}

- (void)getInsightsDataForUID:(NSString *)UID
{
    DLog();
    if ([UID isEqualToString:@""])
    {
        DLog(@"No UID exists - creating emtpy Insights dictionary");
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", AMB_INSIGHTS_URL, UID];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          DLog();
          if (!error)
          {
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
    NSLog(@"Preparig to send Identify data");
    // Create the payload to send
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   @"email" : self.email,
                                                                                   @"fp" : self.identifyData,
                                                                                   @"mbsy_source" : @"",
                                                                                   @"mbsy_cookie_code" : @""
                                                                                   }];
    
    //Create the POST request
    NSURL *url = [NSURL URLWithString:AMB_IDENTIFY_SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:AMB_AUTHORIZATION_TOKEN forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      if (!error)
                                      {
                                          NSLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                                          
                                          //Check for 2xx status codes
                                          if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                                              ((NSHTTPURLResponse *)response).statusCode < 300)
                                          {
                                              NSLog(@"Response from backend from sending identify: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                                          }
                                      }
                                      else
                                      {
                                          NSLog(@"Error: %@", error.localizedDescription);
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
    [self performSelector:@selector(identify)
               withObject:self
               afterDelay:AMB_IDENTIFY_RETRY_TIME];
}



#pragma mark - PTPusherDelegate
- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
{
    NSLog(@"Channel: %@\nRequest body: %@", channel.name, [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding]);
    
    // Modify the default autheticate request that Pusher will make. The
    // HTTP body is set per Ambassador back end requirements
    [request setValue:AMB_AUTHORIZATION_TOKEN forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *httpBodyString = [[NSMutableString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding];
    NSMutableDictionary *httpBody = parseQueryString(httpBodyString);
    httpBody = [NSMutableDictionary dictionaryWithDictionary:@{
                                                               @"auth_type" : @"private",
                                                               @"channel" : channel.name,
                                                               @"socket_id" : httpBody[@"socket_id"]
                                                               }];
    
    __autoreleasing NSError *e = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:&e];
    if (!e)
    {
        request.HTTPBody = bodyData;
    }
    else
    {
        NSLog(@"Error serializing pusher channel subscription request's HTTPBody - %@", e.description);
    }
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"%@ - %@",channel.name, error.debugDescription);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"Subscribed to: %@", channel.name);
}

@end
