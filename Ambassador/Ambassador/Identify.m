//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "Identify.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface Identify () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) void (^completion)(NSMutableDictionary *r, NSError *e);
@end

@implementation Identify
NSString * const SIGNAL_URL = @"ambassador";

- (id)init {
    if (self = [super init]) {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
    }
    return self;
}

- (void)identifyWithURL:(NSString *)url completion:(void (^)(NSMutableDictionary *, NSError *))completion {
    self.completion = completion;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
}

- (void)extractAugurVariable:(NSString *)var {
    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
    NSString *dataStr = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
    
    [self completionWithResponse:returnVal error:e];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *reqStr = [[request URL] absoluteString];
    NSArray *reqStrComponents = [reqStr componentsSeparatedByString:@":"];
    if (reqStrComponents.count > 1 && [(NSString *)reqStrComponents[0] isEqualToString:SIGNAL_URL]) {
        [self extractAugurVariable:@"augur.json"];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        NSString *locDesc = @"Operation was unsuccessful.";
        NSString *failReason = [NSString stringWithFormat:@"The operation recieved a %ld response from the server.", (long)response.statusCode];
        NSString *recSugguest =  @"Check the network";
        
        [self completionWithResponse:nil error:errorMake(locDesc, failReason, recSugguest, response.statusCode)];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self completionWithResponse:nil error:error];
}

- (void)completionWithResponse:(NSMutableDictionary *)r error:(NSError *)e {
    if (self.completion) {
        __weak Identify *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completion(r, e);
        });
    }
}

@end
