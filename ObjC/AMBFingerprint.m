//
//  AMBFingerprint.m
//  ObjC
//
//  Created by Diplomat on 5/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBFingerprint.h"
@interface AMBFingerprint () <UIWebViewDelegate>

@property UIWebView* webView;
@property NSString* urlString;
@property NSString* keyString;
@property NSError* error;

@property BOOL sucessfulNetworkCall;

@end

@implementation AMBFingerprint

#pragma mark - Initialization


- (id)init {
    self = [super init];
    
    if (self) {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
        self.sucessfulNetworkCall = YES;
        self.urlString = @"http://127.0.0.1:7999/augur.html";
    }
    
    return self;
}

#pragma mark - Deallocation


#pragma mark - Fingerprinting

- (void)registerFingerprint {
    NSURL* url = [NSURL URLWithString:self.urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)getFingerprintJSON {
    //Request the JS variable on the webView's page
    //  NOTE:
    //      JSONdata is a var in the javascript that gets assigned the
    //      strigified version of the JSON returned by Augur inside
    //      the javascript callback function used by augur. This gets
    //      assigned to JSONDataString.
    NSString* JSONDataString = [self.webView stringByEvaluatingJavaScriptFromString:@"JSONdata"];
    
    //Create NSData from the string so we can parse it
    NSData* JSONData = [JSONDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    //Parse JSONData
    NSError* e;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
    
    if (e) {
        NSLog(@"Unable to parse JSON reponse\n%@", e);
    } else {
        self.jsonResponse = json;
        
        //Log the JSON
        NSLog(@"Data from JSON reponse:\n\tDID: %@\n\tUID: %@", self.jsonResponse[@"device"][@"ID"], self.jsonResponse[@"consumer"][@"UID"]);
        
        //Notify the app that the JSON is ready
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AMBFingerprintDidGetJSON" object:self];
        
        //Save the data to User Defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:json forKey:@"fingerprintJSON"];
        [defaults synchronize];
    }
}

- (NSDictionary*)returnJsonReponse {
    return self.jsonResponse;
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Break apart request URL
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    //Check for the request attempted in the augur javascript callback
    //located in the HTML
    if ([components count] > 1 &&
        [(NSString *)[components objectAtIndex:0] isEqualToString:@"myapp"]) {
            [self getFingerprintJSON];
            return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Get the status code of the webView response for error checking
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] init];
    NSCachedURLResponse* cachedResponse =
        [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    response = (NSHTTPURLResponse*)cachedResponse.response;
    
    if (response.statusCode == 200 || response.statusCode == 202) {
        //Successful request (202 means sucuessful but using TOR)
        NSLog(@"Sucessful fingerprint - status code: %ld", (long)response.statusCode);
    } else {
        //Create and log the error
        NSError* e = [NSError errorWithDomain:@"HTML Status Code" code:response.statusCode userInfo:nil];
        NSLog(@"Non successful fingerprint:\n%@", e);
        
        //Set applicable local properties
        self.error = e;
        self.sucessfulNetworkCall = false;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //Log the error
    NSLog(@"webView failed to load:\n%@", error);
    
    //Set applicable local properties
    self.error = error;
    self.sucessfulNetworkCall = false;
}

@end
