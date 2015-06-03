//
//  TestWelcomeViewController.m
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#import "Ambassador.h"
#import "TestWelcomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TestWelcomeViewController ()

@property UIImageView *avatar;
@property UINavigationBar *navBar; //
@property UIButton *back;
@property UIView *topView;
@property UILabel *welcomeMessage;
@property NSMutableDictionary *preferences;

@end

@implementation TestWelcomeViewController

- (id)initWithPreferences:(NSMutableDictionary *)preferences
{
    if ([super init])
    {
        self.preferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
        
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        self.welcomeMessage = [UILabel new];
        self.welcomeMessage.text = [NSString stringWithFormat:@"Welcome %@,\n\n%@ sent you here!\nHere is a bunch of text blah blah blah blah ldksfjd;sfjds;lafjas;dlfjads;lfjads;fjads;lfjads;lkfjads;fjads;lkfjdsal;", preferences[@"refererFN"], preferences[@"friendFN"]];
        self.welcomeMessage.numberOfLines = 0;
        self.welcomeMessage.translatesAutoresizingMaskIntoConstraints = NO;
        self.welcomeMessage.textAlignment = NSTextAlignmentCenter;
        self.welcomeMessage.textColor = [UIColor whiteColor];
        [self.view addSubview:self.welcomeMessage];
        
        self.avatar = [[UIImageView alloc] init];
        self.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        self.avatar.layer.borderWidth = 3.0;
        self.avatar.layer.cornerRadius = 150 / 2;  //TODO: get size from api
        self.avatar.clipsToBounds = YES;
        self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.avatar];
        
        self.navBar = [[UINavigationBar alloc] init];
        self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.navBar.tintColor = [UIColor blackColor];
        self.navBar.translucent = NO;
        //[self.view addSubview:self.navBar];
        
        self.back = [[UIButton alloc] init];
        self.back.translatesAutoresizingMaskIntoConstraints = NO;
        self.back.backgroundColor = [UIColor whiteColor];
        [self.back addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.back setTitle:@"Continue" forState:UIControlStateNormal];
        [self.back setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.view addSubview:self.back];

        
        self.topView =  [[UIButton alloc] init];
        self.topView.translatesAutoresizingMaskIntoConstraints = NO;
        self.topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.topView];
        
        //TODO: Set preferences here
        NSDictionary *color = self.preferences[@"backgroundColor"];
        float red = [(NSNumber *)color[@"red"] floatValue];
        float green = [(NSNumber *)color[@"green"] floatValue];
        float blue = [(NSNumber *)color[@"blue"] floatValue];
        self.view.backgroundColor = Rgb2UIColor(red, green, blue);
        
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:self.view
//                                                              attribute:NSLayoutAttributeHeight
//                                                             multiplier:0.0
//                                                               constant:50.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.9
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.welcomeMessage
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.2
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.2
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatar
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.welcomeMessage
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:-25.0]];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.back
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:100.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.back
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.back
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.back
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:20.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:self.preferences[@"image"]]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error)
            {
                self.avatar.hidden = YES;
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.avatar.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    [self.avatar setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButton:(UIBarButtonItem *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
}

@end
