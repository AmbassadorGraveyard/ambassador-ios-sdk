//
//  NoAccountViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/30/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "NoAccountViewController.h"

@interface NoAccountViewController () <UIWebViewDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIWebView * webView;
@property (nonatomic, strong) IBOutlet UIView * headerView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * spinner;

@end


@implementation NoAccountViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Loads up webview
    NSURL *scheduleDemoURL = [NSURL URLWithString:@"http://www.getambassador.com/schedule-a-demo"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:scheduleDemoURL]];
    self.webView.delegate = self;
    
    // Sets colors
    self.view.backgroundColor = self.headerView.backgroundColor;
    self.webView.backgroundColor = self.headerView.backgroundColor;
}


#pragma mark - Actions

- (IBAction)closePage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView  {
    [self.spinner stopAnimating];
}

@end
