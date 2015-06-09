//
//  CutomTabBarController.m
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "CutomTabBarController.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>

@interface CutomTabBarController () <MFMailComposeViewControllerDelegate>

@property UILabel *titleLabel;
@property UIButton *cancelButton;
@property UIView *containerView;
@property SLComposeViewController *slComposeViewController;
@property MFMailComposeViewController *mailComposeViewcontroller;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSMutableArray *tabBarButtons;
@property (nonatomic, strong) NSArray *viewControllers;

@end


@implementation CutomTabBarController

#pragma mark - Inits
- (id)initWithUIPreferences:(NSMutableDictionary *)preferences andSender:(id)sender
{
    if ([super init])
    {
        //Initializing containers
        self.sender = sender;
        self.UIPreferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
        self.services = [[NSArray alloc] initWithArray:self.UIPreferences[@"services"]];
        self.tabBarButtons = [[NSMutableArray alloc] init];
        
        //Set up main view
        self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];
        
        //Set up container view
        self.containerView = [[UIView alloc] init];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.view addSubview:self.containerView];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        //Set up cancel view
        self.cancelButton = [[UIButton alloc] init];
        self.cancelButton.backgroundColor = [UIColor redColor];
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.cancelButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:50.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        
        //Set up title view
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = @"Spread the word";
        self.titleLabel.textColor = [UIColor blackColor];
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24];
        [self.view addSubview:self.titleLabel];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:50.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        for (NSDictionary* service in self.services)
        {
            UIButton * btn = [UIButton new];
            [btn setTitle:service[@"title"] forState:UIControlStateNormal];
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            [btn addTarget:self action:@selector(tabButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor clearColor]];
            btn.imageView.contentMode = UIViewContentModeCenter;
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
            
            //TODO: Set target action
            //TODO: Set background colors and stuff here
            [self.tabBarButtons addObject:btn];
        }
        
        for (int i = 0; i < self.tabBarButtons.count; ++i)
        {
            UIButton *btn = (UIButton *)self.tabBarButtons[i];
            //TODO: set height from parameter and vertical padding
            [self.view addSubview:btn];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.containerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0.0
                                                                   constant:50.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.containerView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0 / self.services.count
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.containerView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            if (btn == [self.tabBarButtons firstObject])
            {
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0]];
            }
            else
            {
                UIButton *previousBtn = (UIButton *)self.tabBarButtons[i - 1];
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:previousBtn
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0]];
            }
        }
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)backButton:(UIBarButtonItem *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonPress
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)tabButtonPress:(UIButton *)button
{
    int selectedIndex = 0;
    for (int i = 0; i < self.tabBarButtons.count; ++i)
    {
        UIButton *btn = (UIButton *)self.tabBarButtons[i];
        if (btn == button)
        {
            btn.selected = YES;
            btn.backgroundColor = [UIColor whiteColor];
            selectedIndex = i;
        }
        else
        {
            btn.selected = NO;
            btn.backgroundColor = [UIColor blackColor];
        }
    }
    
    [self cancelButtonPress];
    
    NSString *serviceTitle = [NSString stringWithString:self.services[selectedIndex][@"title"]];
    if ([serviceTitle isEqualToString:@"twitter"])
    {
        self.slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self.slComposeViewController setInitialText:@"First post from my iPhone app"];
        [self.presentingViewController presentViewController:self.slComposeViewController animated:YES completion:nil];
    }
    else if ([serviceTitle isEqualToString:@"facebook"])
    {
        self.slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self.slComposeViewController setInitialText:@"First post from my iPhone app"];
        [self.presentingViewController presentViewController:self.slComposeViewController animated:YES completion:nil];
    }
    else if ([serviceTitle isEqualToString:@"mail"])
    {
        self.mailComposeViewcontroller = [[MFMailComposeViewController alloc] init];
        self.mailComposeViewcontroller.mailComposeDelegate = self;
        [self.mailComposeViewcontroller setSubject:@"Somthing to share"];
        NSString *emailBody = @"Check out this link: http://www.google.com";
        [self.mailComposeViewcontroller setMessageBody:emailBody isHTML:NO];
        [self.presentingViewController presentViewController:self.mailComposeViewcontroller animated:YES completion:nil];
    }
    else
    {
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled)
    {
        NSLog(@"Cancelled");
    }
    else if (result == MFMailComposeResultFailed)
    {
        NSLog(@"Failed with error, %@", error);
    }
    else if (result == MFMailComposeResultSaved)
    {
        NSLog(@"Saved");
    }
    else if (result == MFMailComposeResultSent)
    {
        NSLog(@"Sent");
    }
    else
    {
        NSLog(@"Other");
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
