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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fingerPrintEngine = [[AMBFingerprint alloc] init];
    [self.fingerPrintEngine registerFingerprint];
    
    self.insightsEngine = [[AMBInsights alloc] init];
    [self.insightsEngine searchByUID:@"655077a40aaf6b75d0c1fe55bd4e0e6c32c074bfadfef5c29c2dfc50" withErrorBlock:^(NSError* error) {
        NSLog(@"%@", error);
    }];
    
    //Set observer on the fingerprintEngine's dictionary
    //so it's only accessed after being set
    [self.fingerPrintEngine addObserver:self forKeyPath:@"jsonResponse" options:0 context:@"JSONFilled"];
    //[self.fingerPrintEngine addObserver:self forKeyPath:@"jsonResponse" options:0 context:@"Fingerprinted"];
    
    [self listSubviewsOfView:self.view withSpacing:@""];
    
}

//The observer handler
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"JSONFilled") {
#ifdef DEBUG
        [self addDevLables];
#endif
    } else if ( context == @"Fingerprinted") {
        self.uid = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, [[UIScreen mainScreen] bounds].size.width, 10)];
        self.uid.text = [NSString stringWithFormat:@"UID: %@",self.fingerPrintEngine.jsonResponse[@"consumer"][@"UID"]];
        self.did = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, [[UIScreen mainScreen] bounds].size.width, 10)];
        self.did.text = [NSString stringWithFormat:@"DID: %@",self.fingerPrintEngine.jsonResponse[@"device"][@"ID"]];
        self.did.font = [UIFont systemFontOfSize:5];
        self.uid.font = [UIFont systemFontOfSize:5];
        [self.view addSubview:self.uid];
        [self.view addSubview:self.did];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)addDevLables {
    /*
    self.jsonResponseText = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.jsonResponseText.text = [NSString stringWithFormat:@"%@", self.fingerPrintEngine
                                  .jsonResponse];
    self.jsonResponseText.font = [UIFont systemFontOfSize:5];
    [self.view addSubview:self.jsonResponseText];
     */
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

@end

