//
//  CampaignListController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "CampaignListController.h"

@interface CampaignListController() <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * tableHeight;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;

// Private properties
@property (nonatomic, strong) NSArray * campaignArray;

@end


@implementation CampaignListController

CGFloat tableCellHeight = 50;
CGFloat tableHeaderHeight = 50;


#pragma mark - LifeCycle

- (instancetype)initWithCampaigns:(NSArray*)campaigns {
    // Gets viewController from storyboard to present
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"campaignList"];
    
    // Inits campaign array
    self.campaignArray = campaigns;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


#pragma mark - Button Actions

- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Datasource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *headerCell = [[UITableViewCell alloc] init];
    
    // Sets up header cell UI
    headerCell.textLabel.textAlignment = NSTextAlignmentCenter;
    headerCell.textLabel.text = @"Campaigns";
    headerCell.textLabel.textColor = [UIColor whiteColor];
    headerCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    headerCell.backgroundColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
    
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.campaignArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    // Grabs the campaign object
    CampaignObject *object = self.campaignArray[indexPath.row];
    
    // Sets up cell label
    cell.textLabel.text = object.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CampaignObject *selectedCampaign = (CampaignObject*)self.campaignArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(campaignListCampaignChosen:)]) { [self.delegate campaignListCampaignChosen:selectedCampaign]; }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UI Functions

- (void)setupUI {
    // TableView
    self.tableHeight.constant = (self.campaignArray.count > 6) ? 300 : (tableCellHeight * self.campaignArray.count) + tableHeaderHeight;
    self.tableView.layer.cornerRadius = 6;
    
    // Button
    [self.btnClose setImage:[self.btnClose.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnClose.tintColor = [UIColor whiteColor];
}

@end
