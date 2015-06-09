//
//  Identify.m
//  Ambassador
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Identify.h"
#import "Constants.h"

@interface Identify () <UIWebViewDelegate>

@property UIWebView* webView;

@end


@implementation Identify

#pragma mark - Inits
- (id)init
{
    if ([super init]) {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
    }
    return self;
}


#pragma mark - API Functions
- (BOOL)identify
{
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY])
//    {
//        //We have Identify
//        //[[NSNotificationCenter defaultCenter] postNotificationName:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
//        //                                                    object:self];
//        // return YES;
//    }

    NSURL *url = [NSURL URLWithString:AMBASSADOR_IDENTIFY_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    return NO;
}


#pragma mark - Network Helper Functions
- (BOOL)getJSON
{
    //
    // Pull the JSON fingerprint string from webView and serialize to dictionary
    //
    NSString *JSONString = [self.webView
                            stringByEvaluatingJavaScriptFromString:AMBASSADOR_IDENTIFY_JAVASCRIPT_VARIABLE_NAME];
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError *e;
    NSMutableDictionary *JSONSerialization = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
    
    //
    // Make sure the JSON was serialized successfully
    //
    if (e)
    {
        NSLog(@"%@\n%@", AMBASSADOR_JSON_PARSE_ERROR, e);
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
        return NO;
    }
    else
    {
        NSLog(@"%@ - size: %f kB", AMBASSADOR_IDENTIFY_DATA_RECIEVED_SUCCESS, (float)JSONData.length / 1024.0f);
        [[NSUserDefaults standardUserDefaults] setObject:JSONSerialization forKey:AMBASSADOR_USER_DEFAULTS_IDENTIFYDATA_KEY];
        self.identifyData = [[NSMutableDictionary alloc] init];
        self.identifyData = JSONSerialization;
        [[NSNotificationCenter defaultCenter] postNotificationName:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION object:self];
        return YES;
    }
}


#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //
    // Parse the URL string delimiting at ":"
    //
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
    
    //
    // Check if the URL is signal URL used in Augur javascript callback
    //
    if (urlRequestComponents.count > 1 &&
        [(NSString *)urlRequestComponents[0] isEqualToString:AMBASSADOR_IDENTIFY_SIGNAL_URL])
    {
        [self getJSON];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //
    // Get the response code
    //
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    
    //
    // Check for a vaild response code
    //
    if (!(response.statusCode == 200 || response.statusCode == 202))
    {
        NSLog(@"%@ - %ld", AMBASSADOR_IDENTIFY_GENERAL_FAIL_ERROR_MESSAGE, (long)response.statusCode);
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0]; // Try again
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@\n%@", AMBASSADOR_IDENTIFY_GENERAL_FAIL_ERROR_MESSAGE, error);
    [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
}

@end
