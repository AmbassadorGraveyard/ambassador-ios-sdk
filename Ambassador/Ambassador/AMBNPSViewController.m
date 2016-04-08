//
//  AMBNPSViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/7/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBNPSViewController.h"

@interface AMBNPSViewController ()

// IBOutlets
@property (nonatomic, strong) IBOutlet UIButton * btnClose;

// Private vars
@property (nonatomic, strong) NSDictionary * payloadDict;

@end


@implementation AMBNPSViewController

#pragma mark - LifeCycle

- (id)initWithPayload:(NSDictionary*)payloadDict {
    // Link up storyboard with the viewController
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[AMBValues AMBframeworkBundle]];
    self = (AMBNPSViewController*)[sb instantiateViewControllerWithIdentifier:@"NPS_MODAL_VIEW"];
    
    // Grab the payload dictionary
    self.payloadDict = [NSDictionary dictionaryWithDictionary: payloadDict];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


#pragma mark - Actions

- (IBAction)closeSurvey:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UI Functions

- (void)setupUI {
    // Buttons
    UIImage *templateImage = [self.btnClose.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.btnClose setImage:templateImage forState:UIControlStateNormal];
    self.btnClose.tintColor = [UIColor whiteColor];
}

@end
