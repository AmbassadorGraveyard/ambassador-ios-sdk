//
//  CampaignListController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "CampaignListController.h"
#import "CampaignObject.h"

@interface CampaignListController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSArray * campaignArray;

@end


@implementation CampaignListController

#pragma mark - LifeCycle

- (instancetype)initWithCampaigns:(NSArray*)campaigns {
    // Gets viewController from storyboard to present
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"campaignList"];
    
    self.campaignArray = campaigns;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.campaignArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    CampaignObject *object = self.campaignArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", object.name, object.campID];
    
    return cell;
}

@end
