//
//  RAFViewController.m
//  ObjC
//
//  Created by Diplomat on 5/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "RAFCollectionViewController.h"
#import "CustomFlow.h"
#import "RAFViewController.h"
//#import "RAFPresentationViewController.h"

@interface RAFViewController ()

@property NSMutableArray* testPhotos;
@property UICollectionView* collectionView;

@end

@implementation RAFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
