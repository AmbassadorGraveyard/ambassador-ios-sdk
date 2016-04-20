//
//  CampaignListController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "CampaignListController.h"
#import "DefaultsHandler.h"
#import "LoadingScreen.h"
#import "AMBUtilities.h"

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

- (instancetype)init {
    // Gets viewController from storyboard to present
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"campaignList"];
    
    [self showCampaignList];
    
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"campaignCell"];
    
    // Grabs the campaign object
    CampaignObject *object = self.campaignArray[indexPath.row];
    
    // Sets up cell label
    cell.textLabel.text = object.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];

    // Sets up detail text label
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", object.campID];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
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
    self.tableView.hidden = self.campaignArray.count == 0;
    
    // Button
    [self.btnClose setImage:[self.btnClose.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnClose.tintColor = [UIColor whiteColor];
    self.btnClose.hidden = self.campaignArray.count == 0;
}


#pragma mark - Helper Functions

- (void)showCampaignList {
    // Sets up request
    NSURL *ambassadorURL;
#if AMBPRODUCTION
    ambassadorURL = [NSURL URLWithString:@"https://api.getambassador.com/campaigns/"];
#else
    ambassadorURL = [NSURL URLWithString:@"https://dev-ambassador-api.herokuapp.com/campaigns/"];
#endif
    
    // Creates Authorization string
    NSString *authString = [NSString stringWithFormat:@"UniversalToken %@", [DefaultsHandler getUniversalToken]];
    
    // Set up headers for request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ambassadorURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    
    [LoadingScreen showLoadingScreenForView:self.view];
    
    // Makes network call
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            // Grab the return dictionary from response
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", results);
            
            // If there are no campaigns
            if ([results[@"count"]  isEqual: @0]) {
                [self dismissViewControllerAnimated:YES completion:^{
                    UIAlertView *noCampAlert = [[UIAlertView alloc] initWithTitle:@"No Campaigns Found" message:@"You must set up at least 1 campaign." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [noCampAlert show];
                }];
            } else {
                // Save the campaign list to defaults and then show list
                [self saveCampaigns:results];
            }
            
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to load campaigns" message:@"Unable to load campaigns at this time. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }];
    }] resume];
}

- (void)saveCampaigns:(NSDictionary*)results {
    // Get list of campaigns
    NSArray *campaignArray = results[@"results"];
    NSMutableArray *arrayToSave = [[NSMutableArray alloc] init];
    
    // Goes through each campaign and creates a campaingObject from that which will be stored to defaults
    for (int i = 0; i < campaignArray.count; i++) {
        NSDictionary *campaign = campaignArray[i];
        CampaignObject *object = [[CampaignObject alloc] init];
        object.name = campaign[@"name"];
        object.campID = [NSString stringWithFormat:@"%@", campaign[@"uid"]];
        
        [arrayToSave addObject:object];
    }

    // Set the local campaign array to values from server and reload
    self.campaignArray = [NSArray arrayWithArray:arrayToSave];
    [self.tableView reloadData];
    [self setupUI];
    [LoadingScreen hideLoadingScreenForView:self.view];
}

@end
