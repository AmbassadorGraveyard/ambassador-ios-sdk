//
//  CutomTabBarController.m
//  test
//
//  Created by Diplomat on 6/2/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "CutomTabBarController.h"

@interface CutomTabBarController ()

@property UIButton *btnone;
@property UIButton *btntwo;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) UIView *placeholderView;
@property (nonatomic, strong) NSArray *tabBarButtons;
@property NSArray *viewControllers;
@property UINavigationBar *navBar;
@property UIBarButtonItem *backBuutton;
@property UINavigationItem *navBarItem;

@end

@implementation CutomTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.navBar = [[UINavigationBar alloc] init];
    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navBar.tintColor = [UIColor blackColor];
    self.navBar.translucent = NO;
    self.backBuutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    self.navBarItem = [[UINavigationItem alloc] init];
    self.navBarItem.title = @"refer a friend";
    
    self.navBarItem.leftBarButtonItem = self.backBuutton;
    self.navBar.items = @[self.navBarItem];
    [self.view addSubview:self.navBar];
    self.btnone = [[UIButton alloc] init];
    self.btntwo = [[UIButton alloc] init];
    self.btnone.backgroundColor = [UIColor redColor];
    self.btntwo.backgroundColor = [UIColor orangeColor];
    self.btnone.translatesAutoresizingMaskIntoConstraints = NO;
    self.btntwo.translatesAutoresizingMaskIntoConstraints = NO;

    [self.btnone addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.btntwo addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    UIViewController *vcOne = [[UIViewController alloc] init];
    UIViewController *vcTwo = [[UIViewController alloc] init];
    vcOne.view.backgroundColor = [UIColor redColor];
    vcTwo.view.backgroundColor = [UIColor orangeColor];
    self.viewControllers = @[vcOne, vcTwo];
    [self loadViewController:vcOne];
    NSLog(@"%@", self.childViewControllers);
    [self.view addSubview:self.btnone];
    [self.view addSubview:self.btntwo];
    
    NSDictionary *views = @{
                            @"btnone" : self.btnone,
                            @"btntwo" : self.btntwo
                            
                            };
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnone attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnone attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnone attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnone attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:80.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btntwo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:50.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btntwo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btntwo attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.btnone attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btntwo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:80.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:80.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    

}

- (void)backButton:(UIBarButtonItem *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonPress:(UIButton *)button
{
    if (button == self.btnone) {
        [self loadViewController:self.viewControllers[0]];
    } else {
        [self loadViewController:self.viewControllers[1]];
    }
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
        vc.view.frame = CGRectMake(0, 130, screen.width, screen.height);
        self.currentViewController = vc;
        return;
    }
    
    vc.view.frame = CGRectMake(0, 130, screen.width, screen.height);
    
    [self transitionFromViewController:self.currentViewController
                      toViewController:vc
                              duration:5
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

- (void)displayContentController:(UIViewController *)content fromController:(UIViewController *)from
{
//    if (self.currentViewController) {
//        [self removeCurrentViewController];
//    }
    
    [self addChildViewController:content];
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];
    [from willMoveToParentViewController:nil];
    
    [self transitionFromViewController:from
                      toViewController:content
                              duration:5
                               options:0
                            animations:nil
                            completion:^(BOOL finished) {
                                [content didMoveToParentViewController:self];
    }];
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
