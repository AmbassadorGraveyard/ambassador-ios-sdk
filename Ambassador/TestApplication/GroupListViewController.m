//
//  GroupListViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "GroupListViewController.h"
#import "LoadingScreen.h"
#import "DefaultsHandler.h"
#import "GroupObject.h"

@interface GroupListViewController() <UITableViewDelegate, UITableViewDataSource>

// IBOutlets
@property (nonatomic, strong) IBOutlet UITableView * tableView;

// Private properties
@property (nonatomic, strong) NSArray * groupArray;

@end


@implementation GroupListViewController

CGFloat groupTableCellHeight = 50;
CGFloat groupTableHeaderHeight = 50;


#pragma mark - LifeCycle

- (instancetype)init {
    // Gets viewController from storyboard to present
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"groupList"];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showGroupList];
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
    return groupTableHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"groupCell"];
    
    // Grabs the campaign object
    GroupObject *object = self.groupArray[indexPath.row];
    
    // Sets up cell label
    cell.textLabel.text = object.groupName;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    
    // Sets up detail text label
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", object.groupID];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return groupTableCellHeight;
}


#pragma mark - Helper Functions

- (void)showGroupList {
    // Sets up request
    NSURL *ambassadorURL;
#if AMBPRODUCTION
    ambassadorURL = [NSURL URLWithString:@"https://api.getambassador.com/groups/"];
#else
    ambassadorURL = [NSURL URLWithString:@"https://dev-ambassador-api.herokuapp.com/groups/"];
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
            
            // If there are no groups
            if ([results[@"count"]  isEqual: @0]) {
                [self dismissViewControllerAnimated:YES completion:^{
                    UIAlertView *noCampAlert = [[UIAlertView alloc] initWithTitle:@"No Groups Found" message:@"You must set up at least 1 group." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [noCampAlert show];
                }];
            } else {
                // Save the groups and show the list
                [self saveGroups:results];
            }
            
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to load groups" message:@"Unable to load groups at this time. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }];
    }] resume];
}

- (void)saveGroups:(NSDictionary *)results {
    NSArray *groupArray = results[@"results"];
    NSMutableArray *arrayToSave = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < groupArray.count; i++) {
        NSDictionary *group = groupArray[i];
        NSString *name = group[@"group_name"];
        NSString *groupID = group[@"group_id"];
        NSString *UID = group[@"uid"];
        
        GroupObject *object = [[GroupObject alloc] initWithName:name ID:groupID UID:UID];
        [arrayToSave addObject:object];
    }
    
    self.groupArray = [NSArray arrayWithArray:arrayToSave];
    [self.tableView reloadData];
    [LoadingScreen hideLoadingScreenForView:self.view];
}

@end
