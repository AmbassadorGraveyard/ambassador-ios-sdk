//
//  FingerPrintViewController.m
//  ObjC
//
//  Created by Diplomat on 5/12/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "FingerPrintViewController.h"
#import "AMBFingerprint.h"
#import "AMBInsights.h"
#import "CustomActivityViewOne.h"

@interface FingerPrintViewController ()

@property AMBFingerprint* fingerPrintEngine;
@property AMBInsights* insightsEngine;
@property NSDictionary* json;

//DEV OBJECTS
@property UILabel* uid;
@property UILabel* did;
@property UITextView* jsonResponseText;

@end

@implementation FingerPrintViewController
- (IBAction)testButton:(UIButton *)sender {
    [self testActiityViewController];
}
- (IBAction)regButton:(UIButton *)sender {
    //[self testPopoverController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fingerPrintEngine = [[AMBFingerprint alloc] init];
    [self.fingerPrintEngine registerFingerprint];
    
    //Set observer on the fingerprintEngine's dictionary
    //so it's only accessed after being set
    [self.fingerPrintEngine addObserver:self forKeyPath:@"jsonResponse" options:0 context:@"JSONFilled"];
    
    //[self listSubviewsOfView:self.view withSpacing:@""];
    
}

//The observer handler
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View Heirarchy Management

//Development utility function
- (void)listSubviewsOfView:(UIView *)view withSpacing:(NSString*)spacing {

    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@%p", spacing, subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview withSpacing:[NSString stringWithFormat:@"%@  ",spacing]];
    }
}

- (void)testActiityViewController {
    NSString* messageText = @"blah blah blah link link stuff message blah";
    NSURL* messageUrl = [NSURL URLWithString:@"http://www.getambassador.com"];
    UIImage* messageImage = [UIImage imageNamed:@"slack-imgs.com.gif"];
    
    NSArray* activityItems = [NSArray arrayWithObjects:messageText, messageUrl, messageImage, nil];
    
    CustomActivityViewOne* activityVC = [[CustomActivityViewOne alloc] init];
    
    
    NSArray* excludedItems = [NSArray arrayWithObjects:UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, nil];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:[NSArray arrayWithObject:activityVC]];
    
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    activityViewController.excludedActivityTypes = excludedItems;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

- (void)testPopoverController {
    CustomActivityViewOne* activityVC = [[CustomActivityViewOne alloc] init];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:nil
                                                        applicationActivities:[NSArray arrayWithObject:activityVC]];

    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [popover
     presentPopoverFromRect:rect inView:self.view
     permittedArrowDirections:0
     animated:YES];
}

@end

