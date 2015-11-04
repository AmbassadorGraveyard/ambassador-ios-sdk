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

- (void)viewDidAppear:(BOOL)animated {
    [AmbassadorSDK runWithUniversalToken:@"9de5757f801ca60916599fa3f3c92131b0e63c6a" universalID:@"abfd1c89-4379-44e2-8361-ee7b87332e32" viewController:self];

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
    clickConversion.mbsy_email = @"jake@getambassador.com";
    
    [AmbassadorSDK registerConversion:clickConversion completion:nil];
}

@end
