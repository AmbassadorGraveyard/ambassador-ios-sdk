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
#import "AMBNetworkObject.h"
#import "AMBPusherChannelObject.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBUtilities.h"


@interface AMBIdentify () <SFSafariViewControllerDelegate, UIWebViewDelegate>
@property UIWebView *webview;

@property (nonatomic, copy) void (^completion)(NSMutableDictionary *resp, NSError *e);
@property (nonatomic, strong) SFSafariViewController * safariVC;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSTimer * identifyTimer;

@end

@implementation AMBIdentify

- (void)identifyWithUniversalID:(NSString*)universalID completion:(void(^)(NSMutableDictionary *returnDict, NSError *error))completion {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9.0) {
        [self performIdentifyForiOS9];
        self.identifyTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(performIdentifyForiOS9) userInfo:nil repeats:YES];
    } else {
        DLog(@"Performing Identify with UIWebView for iOS 8");
        [self identifyWithURL:[AMBValues identifyUrlWithUniversalID:universalID] completion:^(NSMutableDictionary *resp, NSError *e) {
            [AMBValues setDeviceFingerPrintWithDictionary:resp];
        }];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.webview = [[UIWebView alloc] init];
        self.webview.delegate = self;
        self.webview.hidden = YES;
        self.fp = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)performIdentifyForiOS9 {
    self.safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[AMBValues identifyUrlWithUniversalID:[AmbassadorSDK sharedInstance].universalID]]];
    DLog(@"Performing Identify with SAFARI VC for iOS 9");
    [self.safariVC.view setHidden:YES];
    self.safariVC.delegate = self;
    
    UIViewController *rootVC = [UIApplication sharedApplication].windows[0].rootViewController;
    
    if (![self.safariVC.view isDescendantOfView:rootVC.view]) {
        [rootVC.view addSubview:self.safariVC.view];
        [rootVC addChildViewController:self.safariVC];
    }
}


- (void)identifyWithURL:(NSString *)url completion:(void(^)(NSMutableDictionary *resp, NSError *e))completion {
//    self.completion = completion;
//    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self performDeepLink];
}

- (void)identify {
    if (!self.url || [self.url isEqualToString:@""]) { return; }
    [self identifyWithURL:self.url completion:self.completion];
}

- (void)extractVariable:(NSString *)var {
    NSString *js = [NSString stringWithFormat:@"JSON.stringify(%@)", var];
    NSString *dataStr = [self.webview stringByEvaluatingJavaScriptFromString:js];
    if (dataStr == nil) {
        [self triggerCompletion:nil error:AMBNOVALError()];
        return;
    }
    NSData *dataRaw = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableDictionary *returnVal = [NSJSONSerialization JSONObjectWithData:dataRaw options:0 error:&e];
    self.fp = returnVal;
    [self triggerCompletion:returnVal error:e];
}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    [self.safariVC.view removeFromSuperview];
    [self.safariVC removeFromParentViewController];
    [self.identifyTimer invalidate];
}


#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Parse the URL string delimiting at ":"
    NSString *urlRequestString = [[request URL] absoluteString];
    NSArray *urlRequestComponents = [urlRequestString componentsSeparatedByString:@":"];

    // Check if the URL is signal URL used in Augur javascript callback
    if (urlRequestComponents.count > 1 &&
        [(NSString *)urlRequestComponents[0] isEqualToString:@"ambassador"]) {
        [self extractVariable:@"augur.json"];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     //Get the response code
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse *)cachedResponse.response;
    
    // Check for a vaild response code
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        [self performSelector:@selector(identify) withObject:self afterDelay:10]; // Try again
        //[self triggerCompletion:nil error:AMBBADRESPError(response.statusCode, [[NSData alloc] init])];
    }
}


#pragma mark -
- (void)triggerCompletion:(NSMutableDictionary *)resp error:(NSError *)error {
    __weak AMBIdentify *weakSelf = self;
    if (weakSelf.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completion(resp, error);
        });
    }
}

//#pragma mark -
//+ (NSString *)identifyUrlWithUniversalID:(NSString *)uid {
//    NSString *baseUrl;
//#if AMBPRODUCTION
//    baseUrl = @"https://mbsy.co/universal/landing/?url=ambassador:ios/";
//#else
//    baseUrl = @"https://staging.mbsy.co/universal/landing/?url=ambassador:ios/";
//#endif
//    return [baseUrl stringByAppendingString:[NSString stringWithFormat:@"&universal_id=%@", uid]];
//}

- (void)performDeepLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://staging.mbsy.co/universal/landing/?url=%@:/&universal_id=%@", [self getDeepLinkURL], [AmbassadorSDK sharedInstance].universalID]]];
}

- (NSString*)getDeepLinkURL {
    NSArray *urlArray = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"]];
    NSDictionary *urlSchemeDict = [urlArray objectAtIndex:0];
    NSString *scheme = [urlSchemeDict valueForKey:@"CFBundleURLSchemes"][0];
    
    return scheme;
}

@end