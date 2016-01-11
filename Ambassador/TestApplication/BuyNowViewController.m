//
//  BuyNowViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "BuyNowViewController.h"

@interface BuyNowViewController ()

@property (nonatomic, strong) IBOutlet UIButton * btnBuyNow;

@end

@implementation BuyNowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpTheme {
    self.btnBuyNow.layer.cornerRadius = self.btnBuyNow.frame.size.height/2;
}

@end
