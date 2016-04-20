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
#import "GroupFooterCell.h"
#import "GroupCell.h"

@interface GroupListViewController() <UITableViewDelegate, UITableViewDataSource, GroupFooterCellDelegate>

// IBOutlets
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * tableHeight;

// Private properties
@property (nonatomic, strong) NSArray * groupArray;
@property (nonatomic, strong) NSMutableArray * selectedGroupArray;

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
    [self setupUI];
    self.selectedGroupArray = [[NSMutableArray alloc] init];
}


#pragma mark - TableView Datasource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *headerCell = [[UITableViewCell alloc] init];
    
    // Sets up header cell UI
    headerCell.textLabel.textAlignment = NSTextAlignmentCenter;
    headerCell.textLabel.text = @"Groups";
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
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
    // Grabs the group object
    GroupObject *object = self.groupArray[indexPath.row];
    BOOL isSelected = [self.selectedGroupArray containsObject:object];
    
    // Set up group cell
    [cell setUpCellWithGroup:object checkmarkVisible:isSelected];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return groupTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return groupTableHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // Sets up footer cell with 'Save' and 'Cancel' buttons and actions
    GroupFooterCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"groupFooterCell"];
    footerCell.delegate = self;
    footerCell.parentViewController = self;
    
    return footerCell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Unselects default row tap
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Grabs the object and cell at the selected index
    GroupObject *groupTapped = self.groupArray[indexPath.row];
    GroupCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Add or removed object to/from selectedGroupArray and fade in/out checkmark
    if ([self.selectedGroupArray containsObject:groupTapped]) {
        [self.selectedGroupArray removeObject:groupTapped];
        [cell fadeCheckmarkVisible:NO];
    } else {
        [self.selectedGroupArray addObject:groupTapped];
        [cell fadeCheckmarkVisible:YES];
    }
}


#pragma mark - Group Cell Delegate

- (void)groupFooterSaveButtonTappedWithGroups:(NSArray *)groups {
    // Tell parent controller that groups have been selected
    [self.delegate groupListSelectedGroups:groups];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UI Functions

- (void)setupUI {
    // TableView
    self.tableHeight.constant = (self.groupArray.count > 6) ? 400 : (groupTableCellHeight * self.groupArray.count) + (groupTableHeaderHeight * 2);
    self.tableView.layer.cornerRadius = 6;
    self.tableView.hidden = self.groupArray.count == 0;
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
    
    // Goes through all of the response objects and gets the values we need
    for (int i = 0; i < groupArray.count; i++) {
        NSDictionary *group = groupArray[i];
        NSString *name = group[@"group_name"];
        NSString *groupID = [NSString stringWithFormat:@"%@", group[@"group_id"]];
        NSString *UID = group[@"uid"];
        
        GroupObject *object = [[GroupObject alloc] initWithName:name ID:groupID UID:UID];
        [arrayToSave addObject:object];
    }
    
    // Sets array and reloads table
    self.groupArray = [NSArray arrayWithArray:arrayToSave];
    [self.tableView reloadData];
    [self setupUI];
    [LoadingScreen hideLoadingScreenForView:self.view];
}

@end
