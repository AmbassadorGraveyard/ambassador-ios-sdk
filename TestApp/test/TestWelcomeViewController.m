//
//  TestWelcomeViewController.m
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//
#import "Ambassador.h"
#import "TestWelcomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TestWelcomeViewController ()

@property UIImageView *avatar;
@property UINavigationBar *navBar;
@property UIButton *back;
@property UINavigationItem *navBarItem;
@property UIView *topView;

@end

@implementation TestWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.navBar.tintColor = [UIColor blackColor];
    self.navBar.translucent = NO;
    //[self.view addSubview:self.navBar];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];
    
    self.avatar = [[UIImageView alloc] init];
    self.avatar.backgroundColor = self.accentColor;
    self.avatar.layer.cornerRadius = 100 / 2;
    self.avatar.clipsToBounds = YES;
    self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.avatar];
    NSMutableDictionary * prefs = [[Ambassador sharedInstance] getPreferencesData];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    self.back = [[UIButton alloc] initWithFrame:CGRectMake(0, screen.height - 75, screen.width, 75)];
    self.back.backgroundColor = [UIColor whiteColor];
    [self.back setTitleColor:self.accentColor forState:UIControlStateNormal];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.back.frame.size.width, 0.25)];
    lineView.backgroundColor = [UIColor blackColor];
    //[self.back addSubview:lineView];
    
    [self.back addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.back setTitle:@"Continue" forState:UIControlStateNormal];
    });
    
  
    [self.view addSubview:self.back];

    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:prefs[@"image"]]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            self.avatar.hidden = YES;
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatar.image = [UIImage imageWithData:data];
        });
    }] resume];
    // Do any additional setup after loading the view.
}

- (void)layoutSubviews
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButton:(UIBarButtonItem *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
