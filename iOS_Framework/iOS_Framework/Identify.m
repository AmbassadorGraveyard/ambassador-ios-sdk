//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Identify.h"
#import "Constants.h"
#import <UIKit/UIKit.h>

@interface Identify () <UIWebViewDelegate>

@property UIWebView *webview;
@property UIView *view;

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


#pragma mark - Augur callback
- (BOOL)getIdentifyData
{
    DLog();
    
    //Pull the data from the webview
    DLog(@"Grabbing the identify data string from webView");
    NSString *identifyDataString = [self.webview
                                    stringByEvaluatingJavaScriptFromString:AMB_IDENTIFY_JS_VAR];
    DLog(@"Converting identify data string to NSData");
    NSData *identifyDataRaw = [identifyDataString dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError *e;
    DLog(@"Attempt to serialize identify data NSData object into Dictionary");
    NSMutableDictionary *identifyData = [NSJSONSerialization
                                         JSONObjectWithData:identifyDataRaw
                                         options:0
                                         error:&e];
    
    if (e)
    {
        DLog(@"Error parsing identify data NSData object: %@", e.debugDescription);
        
        //Try again
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
        return NO;
    }
    else
    {
        DLog(@"Identify data NSData object was serialized. Data: %@", identifyData);
        self.identifyData = [NSMutableDictionary dictionaryWithDictionary:identifyData];
        
        //Save a copy locally
        [[NSUserDefaults standardUserDefaults] setObject:identifyData
                                                   forKey:AMB_IDENTIFY_USER_DEFUALTS_KEY];
        
        //Get insights data
        [self getInsightsData];
        
        return YES;
    }
}

- (void)getInsightsData
{
    DLog();
    if ([self.identifyData[@"consumer"][@"UID"] isEqualToString:@""])
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
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.augur.io/v2/user?key=***REMOVED***&uid=%@", self.identifyData[@"consumer"][@"UID"]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          DLog();
          if (!error)
          {
              if (((NSHTTPURLResponse *)response).statusCode == 200 ||
                  ((NSHTTPURLResponse *)response).statusCode == 202)
              {
                  __autoreleasing NSError *e = nil;
                  NSMutableDictionary *insightsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
                  
                  if (!e)
                  {
                      //Save a copy locally
                      [[NSUserDefaults standardUserDefaults] setObject:insightsData
                                                                forKey:AMB_INSIGHTS_USER_DEFAULTS_KEY];
                      DLog(@"%@", insightsData);
                      
                      //Notify the app
                      [[NSNotificationCenter defaultCenter] postNotificationName:AMB_IDENTIFY_NOTIFICATION_NAME
                                                                          object:self];
                  }
                  else
                  {
                      DLog(@"Error serializing insights data - %@", e.localizedDescription);
                  }
              }
              else
              {
                  DLog(@"Insights network call returned status code - %ld", ((NSHTTPURLResponse *)response).statusCode);
              }
          }
          else
          {
              DLog(@"Error making insights call - %@", error.localizedDescription);
          }
      }] resume];
}



#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog();
    
    //Parse the URL string delimiting at ":"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
    DLog(@"Url components: %@", urlRequestComponents);
    
    //Check if the URL is signal URL used in Augur javascript callback
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
    
    //Get the response code
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


@end
