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
#import "ThemeHandler.h"
#import "DefaultsHandler.h"

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UITableView * rafTable;

// Private properties
@property (nonatomic, strong) NSArray * rafArray;

@end


@implementation ReferAFriendViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.rafArray = [DefaultsHandler getThemeArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavBarButtons];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Button Actions

- (void)addNewRAF {
    // TODO: Replace with presenting RAF customizer
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Theme" message:@"Type your theme name below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)editRAF {
    // TODO: Add ability to edit RAF
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rafArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAFCell *rafCell = [tableView dequeueReusableCellWithIdentifier:@"rafCell"];
    
    if (rafCell) {
        [rafCell setUpCellWithRaf:self.rafArray[indexPath.row]];
        return rafCell;
    }
    
    // If there is no cell, a blank cell is created so that the cell separator is not shown
    UITableViewCell *blankCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return blankCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.6f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    return headerView;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *campaignId = @"1026"; // TEMPORARY
    
    // Gets RAFItem at array and presents a raf using the plist name value
    RAFItem *item = self.rafArray[indexPath.row];
    [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:item.plistFullName];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If user clicks save
    if (buttonIndex == 1) {
        NSString *themeName = [[alertView textFieldAtIndex:0] text];
        [self saveNewTheme:themeName];
    }
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


#pragma mark - Helper Functions

- (void)reloadThemes {
    self.rafArray = [DefaultsHandler getThemeArray];
    [self.rafTable reloadData];
}

- (void)saveNewTheme:(NSString*)themeName {
    // Creates a new RAF item which will be stored to defaults
    RAFItem *item = [[RAFItem alloc] init];
    item.rafName = themeName;
    item.plistFullName = [NSString stringWithFormat:@"AMBTESTAPP%@", themeName];
    item.dateCreated = [NSDate date];
    
    // Saves a new plist item using the RAF item name
    ThemeHandler *handler = [[ThemeHandler alloc] init];
    [handler saveNewTheme:item];
    
    [self reloadThemes];
}

@end
