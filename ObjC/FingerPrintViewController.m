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
@import Twitter;

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
    //[self testActiityViewController];
}
- (IBAction)regButton:(UIButton *)sender {
    TWTweetComposeViewController *tweetComposeViewController =
    [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:@"Lorem ipsum dolor sit amet."];
    [self.navigationController presentViewController:tweetComposeViewController
                                            animated:YES
                                          completion:^{
                                              //...
                                          }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fingerPrintEngine = [[AMBFingerprint alloc] init];
    [self.fingerPrintEngine registerFingerprint];
    
    //Set observer on the fingerprintEngine's dictionary
    //so it's only accessed after being set
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleObserver:) name:@"AMBFingerprintDidGetJSON" object:nil];
    
    //[self listSubviewsOfView:self.view withSpacing:@""];
}

//The observer handler
- (void)handleObserver:(NSNotification*)notification {
    NSLog(@"JSON recieved");
}
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
//- (void)listSubviewsOfView:(UIView *)view withSpacing:(NSString*)spacing {
//    // Get the subviews of the view
//    NSArray *subviews = [view subviews];
//    // Return if there are no subviews
//    if ([subviews count] == 0) return; // COUNT CHECK LINE
//    for (UIView *subview in subviews) {
//        // Do what you want to do with the subview
//        NSLog(@"%@%p", spacing, subview);
//        // List the subviews of subview
//        [self listSubviewsOfView:subview withSpacing:[NSString stringWithFormat:@"%@  ",spacing]];
//    }
//}

@end

