//
//  ViewController.m
//  test
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import "Ambassador.h"

@interface ViewController ()

@property UIButton *button;
@property UIButton *buttontoo;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [Ambassador registerConversionWithEmail:@"email@website.com"];
    
    self.button = [[UIButton alloc]init];
    self.button.backgroundColor = [UIColor greenColor];
    [self.button addTarget:self action:@selector(buttonStuff) forControlEvents:UIControlEventTouchUpInside];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.button setTitle:@"RAF" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    self.buttontoo = [[UIButton alloc]init];
    self.buttontoo.backgroundColor = [UIColor blackColor];
    [self.buttontoo addTarget:self action:@selector(buttonStufftoo) forControlEvents:UIControlEventTouchUpInside];
    self.buttontoo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttontoo setTitle:@"RAF" forState:UIControlStateNormal];
    [self.view addSubview:self.buttontoo];
    self.buttontoo.hidden = YES;
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttontoo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttontoo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttontoo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttontoo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.button attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void)buttonStuff
{
    [Ambassador registerConversionWithEmail:@"email@website.com"];
    [Ambassador presentRAFFromViewController:self];
}

- (void)buttonStufftoo
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)runTestsOnfileInterface
{
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [paths stringByAppendingPathComponent:@"AmbassadorDocuments"];
    NSError *error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
        {
            NSLog(@"Delete directory error: %@", error);
        }
    }
}

@end
