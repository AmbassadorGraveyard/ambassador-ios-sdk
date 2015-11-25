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
    [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self];
    
    AMBConversionParameters *clickConversion = [[AMBConversionParameters alloc] init];
    clickConversion.mbsy_campaign = @260;
    clickConversion.mbsy_revenue = @200;
    clickConversion.mbsy_email = @"corey@getambassador.com";
    
    [AmbassadorSDK registerConversion:clickConversion restrictToInsall:NO completion:nil];
}

@end
