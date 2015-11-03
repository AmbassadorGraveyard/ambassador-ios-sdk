//
//  Identify.m
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//


#import "AMBIdentify.h"
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "AMBErrors.h"
#import <WebKit/WebKit.h>

@interface AMBIdentify () <SFSafariViewControllerDelegate, WKScriptMessageHandler, WKNavigationDelegate>
//@property UIWebView *webview;

@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic, strong) NSString *url;
@end

@implementation AMBIdentify

- (void)identifyWithRootController:(UIViewController*)vc universalID:(NSString*)universalID completion:(void(^)(NSMutableDictionary *returnDict, NSError *error))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://preview.augur.io/ci"]];
    self.safariVC = [[SFSafariViewController alloc] initWithURL:request.URL];
    [vc presentViewController:self.safariVC animated:NO completion:nil];
}

//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    [self.webview evaluateJavaScript:@"window.mbsy_short_code" completionHandler:^(NSString * javascript, NSError * _Nullable error) {
//        NSString *shortCodeString =  javascript;
//        NSLog(@"%@", shortCodeString);
//    }];
//}


//- (instancetype)init {
//    if (self = [super init]) {
//        self.webview = [[UIWebView alloc] init];
//        self.webview.delegate = self;
//        self.webview.hidden = YES;
//        self.fp = [[NSMutableDictionary alloc] init];
//    }
//    return self;
//}
//
//
//- (void)identifyWithURL:(NSString *)url completion:(void(^)(NSMutableDictionary *resp, NSError *e))completion {
//    self.completion = completion;
//    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//}
//
//- (void)identify {
//    if (!self.url || [self.url isEqualToString:@""]) { return; }
//    [self identifyWithURL:self.url completion:self.completion];
//}
//
//- (void)extractVariable:(NSString *)var {
//    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
//    NSString *dataStr = [self.webview stringByEvaluatingJavaScriptFromString:js];
//    if (dataStr == nil) {
//        [self triggerCompletion:nil error:AMBNOVALError()];
//        return;
//    }
//    NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *e = nil;
//    NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
//    self.fp = returnVal;
//    [self triggerCompletion:returnVal error:e];
//}
//
//
//
//#pragma mark - UIWebViewDelegate
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    // Parse the URL string delimiting at ":"
//    NSString *urlRequestString = [[request URL] absoluteString];
//    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];
//
//    // Check if the URL is signal URL used in Augur javascript callback
//    if (urlRequestComponents.count > 1 &&
//        [(NSString *)urlRequestComponents[0] isEqualToString:@"ambassador"]) {
//        [self extractVariable:@"augur.json"];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//     //Get the response code
//    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
//    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
//    response = (NSHTTPURLResponse *)cachedResponse.response;
//    
//    // Check for a vaild response code
//    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
//        [self performSelector:@selector(identify) withObject:self afterDelay:10]; // Try again
//        //[self triggerCompletion:nil error:AMBBADRESPError(response.statusCode, [[NSData alloc] init])];
//    }
//}
//
//
//#pragma mark -
//- (void)triggerCompletion:(NSMutableDictionary *)resp error:(NSError *)error {
//    __weak AMBIdentify *weakSelf = self;
//    if (weakSelf.completion) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.completion(resp, error);
//        });
//    }
//}

@end