//
//  AMBContactCard.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/5/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBContactCard.h"

@interface AMBContactCard ()

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivContactPhone;
@property (nonatomic, strong) IBOutlet UITableView * infoTableView;

@end

@implementation AMBContactCard


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
