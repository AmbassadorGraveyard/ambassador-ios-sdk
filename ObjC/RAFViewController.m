//
//  RAFViewController.m
//  ObjC
//
//  Created by Diplomat on 5/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ReferAFriendCollectionViewController.h"
#import "ReferAFriendCollectionViewCell.h"
#import "RAFViewController.h"

@interface RAFViewController ()

@property NSMutableArray* testPhotos;
@property UICollectionView* collectionView;
@property ReferAFriendCollectionViewController* controller;

@end

@implementation RAFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)referAFriend:(UIButton *)sender {
    ReferAFriendCollectionViewController* controller = [[ReferAFriendCollectionViewController alloc] init];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:controller animated:YES completion:nil];
}
@end
