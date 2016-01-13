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

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView * rafTable;
@property (nonatomic, strong) IBOutlet UITextField * tfCampaignId;

@property (nonatomic, strong) NSArray * rafNameArray;

@end

@implementation ReferAFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rafTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rafNameArray = @[@"Ambassador Shoes RAF", @"Ambassador RAF", @"Ambassador Shirt RAF"];
    self.tfCampaignId.delegate = self;
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAFCell *rafCell = [tableView dequeueReusableCellWithIdentifier:@"rafCell"];
    [rafCell setUpCellWithRafName:self.rafNameArray[indexPath.row]];
    
    return rafCell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *campaignId = self.tfCampaignId.text;
    
    switch (indexPath.row) {
        case 0:
            [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:@"AmbassadorShoes"];
            break;
        case 1:
            [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:@"AmbassadorTheme"];
            break;
        case 2:
            [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:@"AmbassadorShirt"];
            break;
        default:
            break;
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
