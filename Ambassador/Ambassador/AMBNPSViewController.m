//
//  AMBNPSViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/7/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBNPSViewController.h"
#import "AMBSurveySlider.h"

@interface AMBNPSViewController () <AMBSurveySliderDelegate>

// IBOutlets
@property (nonatomic, weak) IBOutlet UIButton * btnClose;
@property (nonatomic, weak) IBOutlet UIButton * btnSubmit;
@property (nonatomic, weak) IBOutlet AMBSurveySlider * slider;

// Private vars
@property (nonatomic, strong) NSDictionary * payloadDict;
@property (nonatomic, strong) NSString * selectedValue;

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
    [self.slider setUpSliderWithHighNum:10 lowNum:0];
    self.slider.delegate = self;
    
    // Defaults the selectedValue to 5
    self.selectedValue = @"5";
}


#pragma mark - Actions

- (IBAction)closeSurvey:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitTapped:(id)sender {
    NSLog(@"You selected %@", self.selectedValue);
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AMBSurveySlider Delegate

- (void)AMBSurveySlider:(AMBSurveySlider *)surveySlider valueSelected:(NSString *)value {
    self.selectedValue = value;
}


#pragma mark - UI Functions

- (void)setupUI {
    // Close button
    UIImage *templateImage = [self.btnClose.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.btnClose setImage:templateImage forState:UIControlStateNormal];
    self.btnClose.tintColor = [UIColor whiteColor];
    
    // Submit button
    self.btnSubmit.layer.cornerRadius = 4;
}

@end
