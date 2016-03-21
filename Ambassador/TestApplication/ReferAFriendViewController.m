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

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UITableView * rafTable;

// Private properties
@property (nonatomic, strong) NSArray * rafNameArray;

@end

@implementation ReferAFriendViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.rafNameArray = @[@"Ambassador Shoes RAF", @"Ambassador RAF", @"Ambassador Shirt RAF", @"Custom Branded RAF"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavBarButtons];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Button Actions

- (void)addNewRAF {
    // TODO: Add customize RAF page
}

- (void)editRAF {
    // TODO: Add ability to edit RAF
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAFCell *rafCell = [tableView dequeueReusableCellWithIdentifier:@"rafCell"];
    
    if (rafCell) {
        [rafCell setUpCellWithRafName:self.rafNameArray[indexPath.row]];
        return rafCell;
    }
    
    UITableViewCell *blankCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return blankCell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *campaignId = @"1026"; // TEMPORARY
    
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
        case 3:
            [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:@"CustomBrandTheme"];
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


#pragma mark - UI Functions

- (void)setupUI {
    // Views
    self.imgBGView.layer.cornerRadius = 5;
    
    // TableView
    self.rafTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setNavBarButtons {
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewRAF)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnAdd;
    
    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editRAF)];
    self.tabBarController.navigationItem.leftBarButtonItem = btnEdit;
}

@end
