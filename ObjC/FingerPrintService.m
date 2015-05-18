//
//  FingerPrintService.m
//  ObjC
//
//  Created by Diplomat on 5/12/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "FingerPrintService.h"
@import UIKit;

@interface FingerPrintService()

@property UIWebView* webView;
@property NSString* urlString;
@property NSURL* NSUrl;
@property NSURLRequest* request;

@end



@implementation FingerPrintService

-(id)init {
    self = [super init];
    
    if (self) {
        self.webView = [[UIWebView alloc] init];
        //FIXME - There should be a default or something
        self.urlString = @"http://127.0.0.1:7999/augur.html";
        self.NSUrl = [NSURL URLWithString:self.urlString];
        self.request = [NSURLRequest requestWithURL:self.NSUrl];
        [self.webView loadRequest:self.request]
        
    }
    
    return self;
}

@end
