//
//  Identify.m
//  Ambassador
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Identify.h"
#import "Constants.h"
#import "Promise.h"

@interface Identify () <UIWebViewDelegate>

@property UIWebView* webView;

@end


@implementation Identify

// Counter for unsuccessful identify attempts
long long count = 0;

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
    NSUserDefaults* defualts = [NSUserDefaults standardUserDefaults];
    if ([defualts dictionaryForKey:NSUserDefaultsKeyName])
    {
        return YES;
    }
    NSURL *url = [NSURL URLWithString:augurFingerprintURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    return NO;
}


#pragma mark - Network Helper Functions
- (BOOL)getJSON
{
    NSString *JSONString = [self.webView
                            stringByEvaluatingJavaScriptFromString:JSONJavascriptVariableName];
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *JSONSerialization = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
    if (error)
    {
        NSLog(@"%@\n%@", JSONParseErrorMessage, error);
        if (count > 25) { return NO; }
        ++count;
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
        return NO;
    }
    else
    {
        count = 0;
        NSLog(@"%f kB", (float)JSONData.length / 1024.0f);
        NSLog(@"%@", fingerprintSuccessMessage);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:JSONSerialization forKey:NSUserDefaultsKeyName];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:JSONCompletedNotificationName
                                                            object:self];
        return YES;
    }
}


#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
    if (urlRequestComponents.count > 1 &&
        [(NSString *)urlRequestComponents[0] isEqualToString:internalURLString])
    {
        [self getJSON];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache]
                                           cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    //TODO: create proper errors to throw for non-200 responses
    if (response.statusCode == 200 || response.statusCode == 202)
    {
        count = 0;
    }
    else
    {
        NSLog(@"%@ - %ld", fingerprintErrorMessage, (long)response.statusCode);
        if (count > 25) { return; }
        ++count;
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@\n%@", webViewFailedToLoadErrorMessage, error);
    if (count > 25) { return;  }
    ++count;
    [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
}


@end
