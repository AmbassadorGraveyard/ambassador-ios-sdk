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
#import "interface.h"

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
    interface *fileInterface = [[interface alloc] init];
    NSString *path =[fileInterface getPathDirectory];
    path = [path stringByAppendingPathComponent:@"identify.data"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"%@", [fileInterface writeDictionary:nil toQueue:@"identify.data"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
                                                            object:self];
        return YES;
    }

    NSURL *url = [NSURL URLWithString:AMBASSADOR_IDENTIFY_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    return NO;
}


#pragma mark - Network Helper Functions
- (BOOL)getJSON
{
    NSString *JSONString = [self.webView
                            stringByEvaluatingJavaScriptFromString:AMBASSADOR_IDENTIFY_JAVASCRIPT_VARIABLE_NAME];
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError *e;
    NSMutableDictionary *JSONSerialization = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&e];
    if (e)
    {
        NSLog(@"%@\n%@", AMBASSADOR_JSON_PARSE_ERROR, e);
        if (count > 25) { return NO; }
        ++count;
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
        return NO;
    }
    else
    {
        count = 0;
        NSLog(@"%@ - size: %f kB", AMBASSADOR_IDENTIFY_DATA_RECIEVED_SUCCESS, (float)JSONData.length / 1024.0f);
        interface *fileInterface = [[interface alloc] init];
        
        if ([fileInterface setUpAmbassadorDocumentsDirectory])
        {
            NSLog(@"%@", [fileInterface writeDictionary:JSONSerialization toQueue:@"identify.data"]);
            self.identifyData = [[NSMutableDictionary alloc] init];
            self.identifyData = JSONSerialization;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:AMBASSADOR_NSNOTIFICATION_IDENTIFYDIDCOMPLETENOTIFICATION
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
        NSLog(@"%@ - %ld", AMBASSADOR_IDENTIFY_GENERAL_FAIL_ERROR_MESSAGE, (long)response.statusCode);
        if (count > 25) { return; }
        ++count;
        [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@\n%@", AMBASSADOR_IDENTIFY_GENERAL_FAIL_ERROR_MESSAGE, error);
    if (count > 25) { return;  }
    ++count;
    [self performSelector:@selector(identify) withObject:self afterDelay:2.0];
}


@end
