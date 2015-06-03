//
//  CutomTabBarController.m
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "CutomTabBarController.h"
#import <MessageUI/MessageUI.h>

@interface CutomTabBarController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property UINavigationBar *navBar;
@property UIBarButtonItem *backBuutton;
@property UINavigationItem *navBarItem;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSMutableArray *tabBarButtons;
@property (nonatomic, strong) NSArray *viewControllers;

@end


@implementation CutomTabBarController

#pragma mark - Inits
- (id)initWithUIPreferences:(NSMutableDictionary *)preferences
{
    if ([super init])
    {
        self.UIPreferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
        self.services = [[NSArray alloc] initWithArray:self.UIPreferences[@"services"]];
        self.tabBarButtons = [[NSMutableArray alloc] init];
        for (NSDictionary* service in self.services)
        {
            UIButton * btn = [UIButton new];
            [btn setTitle:service[@"title"] forState:UIControlStateNormal];
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            [btn addTarget:self action:@selector(tabButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
            
            //TODO: Set target action
            //TODO: Set background colors and stuff here
            [self.tabBarButtons addObject:btn];
        }
        
        for (int i = 0; i < self.tabBarButtons.count; ++i)
        {
            UIButton *btn = (UIButton *)self.tabBarButtons[i];
            //TODO: set hiehgt from parameter and vertical padding
            [self.view addSubview:btn];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0.0
                                                                   constant:50.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0 / self.services.count
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:64.25]];
            
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
        
        [self tabButtonPress:(UIButton *)[self.tabBarButtons firstObject]];
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarItem = [[UINavigationItem alloc] initWithTitle:@"Refer A Friend"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navBar = [[UINavigationBar alloc] init];
    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navBar.tintColor = [UIColor blackColor];
    self.navBar.translucent = NO;
    self.backBuutton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(backButton:)];
    self.navBarItem.leftBarButtonItem = self.backBuutton;
    self.navBar.items = @[ self.navBarItem ];
    [self.view addSubview:self.navBar];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:64.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)backButton:(UIBarButtonItem *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)tabButtonPress:(UIButton *)button
{
    int selectedIndex = 0;
    for (int i = 0; i < self.tabBarButtons.count; ++i)
    {
        UIButton *btn = (UIButton*)self.tabBarButtons[i];
        if (btn == button)
        {
            selectedIndex = i;
            btn.selected = YES;
            btn.backgroundColor = [UIColor blackColor];
        }
        else
        {
            btn.selected = NO;
            btn.backgroundColor = [UIColor whiteColor];
        }
    }
    
    NSString* serviceTitle = self.services[selectedIndex][@"title"];
    UIViewController* vc = [[UIViewController alloc] init];
    
    if ([serviceTitle isEqualToString:@"twitter"])
    {
        vc.view.backgroundColor = [UIColor lightGrayColor];
    }
    else if ([serviceTitle isEqualToString:@"facebook"])
    {
        vc.view.backgroundColor = [UIColor purpleColor];
    }
    else if ([serviceTitle isEqualToString:@"mail"])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        [mail setSubject:@"Ambassador"];
        [mail setMessageBody:@"Mail stuff\nhttp://google.com" isHTML:NO];
        mail.mailComposeDelegate = self;
        [self loadViewController:mail];
    }
    else if ([serviceTitle isEqualToString:@"sms"])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        [mail setSubject:@"Sms wont work cuz it's dumb on the simulator"];
        [mail setMessageBody:@"I wish it were sms stuff\nhttp://google.com" isHTML:NO];
        mail.mailComposeDelegate = self;
        [self loadViewController:mail];
    }
    else
    {
        vc.view.backgroundColor = [UIColor orangeColor];
    }
    
    //[self loadViewController:vc];
}

- (void)loadViewController:(UIViewController *)vc
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    
    if (vc == self.currentViewController) {
        return;
    }
    
    [self addChildViewController:vc];
    if (!self.currentViewController) {
        [self.view addSubview:vc.view];
        vc.view.frame = CGRectMake(0, 114.25, screen.width, screen.height -114.25);
        self.currentViewController = vc;
        return;
    }
    
    vc.view.frame = CGRectMake(0, 114.25, screen.width, screen.height - 114.25);
    
    [self transitionFromViewController:self.currentViewController
                      toViewController:vc
                              duration:0
                               options:0
                            animations:nil
                            completion:^(BOOL finished)
    {
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = vc;
    }];
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
    
}

@end
