//
//  ReferAFriendViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ReferAFriendViewController.h"
#import "RAFCell.h"
#import <Ambassador/Ambassador.h>

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * rafTable;

@property (nonatomic, strong) NSArray * rafNameArray;

@end

@implementation ReferAFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rafTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rafNameArray = @[@"Shopping Cart RAF", @"Login RAF", @"Sign Up RAF", @"Refer a Friend 4"];
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAFCell *rafCell = [tableView dequeueReusableCellWithIdentifier:@"rafCell"];
    [rafCell setUpCellWithRafName:self.rafNameArray[indexPath.row]];
    
    return rafCell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self withThemePlist:nil];
            break;
        case 1:
            [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self withThemePlist:nil];
            break;
        case 2:
            [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self withThemePlist:nil];
            break;
        case 3:
            [AmbassadorSDK presentRAFForCampaign:@"260" FromViewController:self withThemePlist:nil];
            break;
        default:
            break;
    }
}

@end
