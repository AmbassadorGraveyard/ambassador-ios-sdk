//
//  AMBNPSViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/7/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBNPSViewController.h"

@interface AMBNPSViewController ()

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
    // Do any additional setup after loading the view.
}


#pragma mark - Actions

- (IBAction)closeSurvey:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
