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


#pragma mark - Public API
- (void)identifyWithURL:(NSString *)url completion:(void (^)(NSMutableDictionary *resp, NSError *e))completion {
    self.completion = completion;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webview loadRequest:request];
}


#pragma mark -
- (void)extractVariable:(NSString *)var {
    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
    NSString *dataStr = [self.webview stringByEvaluatingJavaScriptFromString:js];
    NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
    [self triggerCompletion:returnVal error:e];
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

@end
