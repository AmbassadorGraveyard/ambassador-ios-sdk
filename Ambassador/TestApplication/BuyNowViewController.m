//
//  BuyNowViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "BuyNowViewController.h"
#import <Ambassador/Ambassador.h>

@interface BuyNowViewController ()

@property (nonatomic, strong) IBOutlet UIButton * btnBuyNow;

@end

@implementation BuyNowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - IBActions

- (IBAction)buyNowTapped:(id)sender {
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginEmail"];
    conversionParameters.mbsy_campaign = @260;
    conversionParameters.mbsy_revenue = @24.99;
    conversionParameters.mbsy_custom1 = @"This is a conversion from the Ambassador iOS Test Application";
    conversionParameters.mbsy_custom2 = @"Buy conversion registered for $24.99";
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error registering install conversion - %@", error);
        } else {
            UIAlertView *purchaseAlert = [[UIAlertView alloc] initWithTitle:@"Purchase successful" message:@"Thank you for buying from Ambassador!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [purchaseAlert show];
        }
    }];
}

- (void)setUpTheme {
    self.btnBuyNow.layer.cornerRadius = self.btnBuyNow.frame.size.height/2;
}

@end
