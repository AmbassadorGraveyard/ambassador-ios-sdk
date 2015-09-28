//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <Ambassador/Ambassador.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *rafButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showRAF:(UIButton *)sender {
<<<<<<< HEAD
   // [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self WithRAFParameters:[[AMBServiceSelectorPreferences alloc]init]];
=======
    [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self];
>>>>>>> 51a335aab3189c0e5d8e0bdbe41cd4ce4a1bbd5e
    
}

@end
