//
//  ViewController.m
//  ObjC
//
//  Created by Diplomat on 5/11/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
//@property (weak, nonatomic) IBOutlet UIWebView *augurWebView;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //FIXME - The rectangle needs to be worked on to determine the proper fram size
    UIWebView* augurWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,1024, 768)];
    NSString* url = @"http://127.0.0.1:7999/augur.html";
    NSURL* NSUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:NSUrl];
    [augurWebView loadRequest:request];
    [self.view addSubview:augurWebView];
    
    //Toggle on and off for fun
    augurWebView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
