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
#import "ValuesHandler.h"
#import "RAFCustomizer.h"
#import "FileWriter.h"
#import <ZipZap/ZipZap.h>
#import "UIActivityViewController+ZipShare.h"
#import "AmbassadorHelper.h"

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, RAFCellDelegate, RAFCustomizerDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UITableView * rafTable;
@property (nonatomic, strong) IBOutlet UILabel * lblTapAdd;

// Private properties
@property (nonatomic, strong) NSArray * rafArray;
@property (nonatomic) BOOL tableEditing;
@property (nonatomic, strong) RAFItem * rafForCustomizer;

@end


@implementation ReferAFriendViewController

NSString * RAF_CUSTOMIZE_SEGUE = @"RAF_CUSTOMIZE_SEGUE";
RAFItem * itemToDelete = nil;
NSInteger shareCellIndex;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self reloadThemesWithFade:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavBarButtons];
}


#pragma mark - Button Actions

- (void)addNewRAF {
    [self performSegueWithIdentifier:RAF_CUSTOMIZE_SEGUE sender:self];
}

- (void)editRAF {
    self.tableEditing = !self.tableEditing;
    [self setNavBarButtons];
    [self reloadThemesWithFade:NO];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:RAF_CUSTOMIZE_SEGUE]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        RAFCustomizer *customizer = nav.viewControllers[0];
        customizer.rafItem = self.rafForCustomizer;
        customizer.delegate = self;
        
        // Resets the selected RAF to nil
        self.rafForCustomizer = nil;
    }
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rafArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAFCell *rafCell = [tableView dequeueReusableCellWithIdentifier:@"rafCell"];
    
    if (rafCell) {
        rafCell.isEditing = self.tableEditing;
        rafCell.delegate = self;
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
    
    if (self.tableEditing) {
        self.rafForCustomizer = self.rafArray[indexPath.row];
        [self performSegueWithIdentifier:RAF_CUSTOMIZE_SEGUE sender:self];
    } else {
        // Gets RAFItem at array and presents a raf using the plist name value
        RAFItem *item = self.rafArray[indexPath.row];
        NSString *campaignId = item.campaign.campID;
        [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self withThemePlist:item.plistFullName];
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Checks to make sure 'Yes' was tapped
    if (buttonIndex == 1) {
        [ThemeHandler deleteRafItem:itemToDelete];
        [self reloadThemesWithFade:YES];
    }
}


#pragma mark - RAFCustomizer Delegate

- (void)RAFCustomizerSavedRAF:(RAFItem *)rafItem {
    [self saveNewTheme:rafItem];
}


#pragma mark - RAFCell Delegate

- (void)RAFCellDeleteTappedForRAFItem:(RAFItem *)rafItem {
    // Shows confirmation alert
    NSString *confirmationString = [NSString stringWithFormat:@"%@ will be permanently deleted.", rafItem.rafName];
    UIAlertView *deleteConfirmation = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:confirmationString delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [deleteConfirmation show];
    
    // Gets rafItem to delete
    itemToDelete = rafItem;
}

- (void)RAFCellExportTappedForRAFItem:(RAFItem *)rafItem {
    // Get the cell that is being exported from and shows a spinner
    shareCellIndex = [self.rafArray indexOfObject:rafItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shareCellIndex inSection:0];
    RAFCell *cell = [self.rafTable cellForRowAtIndexPath:indexPath];
    [cell showSpinnerForExport];
    
    // Once the spinner is showing, we export the RAF
    [AmbassadorHelper setDelay:0.2 finished:^{
        [self exportRAFTheme:rafItem];
    }];
}


#pragma mark - UI Functions

- (void)setupUI {
    // Views
    self.imgBGView.layer.cornerRadius = 5;
    
    // TableView
    self.rafTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setNavBarButtons {
    // Changes button title based on editing state
    NSString *editTitle = (self.tableEditing && self.rafArray.count >= 1) ? @"Done" : @"Edit";
    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:editTitle style:UIBarButtonItemStylePlain target:self action:@selector(editRAF)];
    self.tabBarController.navigationItem.leftBarButtonItem = self.rafArray.count == 0 ? nil : btnEdit;
    
    // Decides whether or not to show '+' button based on editing state
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewRAF)];
    self.tabBarController.navigationItem.rightBarButtonItem = [editTitle isEqualToString:@"Done"] ? nil : btnAdd;
    
    self.tabBarController.title = @"Refer a Friend";
}


#pragma mark - Helper Functions

- (void)reloadThemesWithFade:(BOOL)fade {
    self.rafArray = [DefaultsHandler getThemeArray];
    self.lblTapAdd.hidden = (self.rafArray.count > 0) ? YES : NO;
    
    if (self.rafArray.count == 0) {
        self.tableEditing = NO;
    }
    
    [self setNavBarButtons];
    
    // Only perform fade if deleting or adding
    if (fade) {
        [self.rafTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.rafTable reloadData];
    }
}

- (void)saveNewTheme:(RAFItem*)saveItem {
    // Saves a new plist item using the RAF item name and reloads table
    [ThemeHandler saveTheme:saveItem];
    [self reloadThemesWithFade:YES];
    
    // Packages zip up after the reload
    [ThemeHandler packageZipForRAF:saveItem];
}

- (void)exportRAFTheme:(RAFItem*)rafItem {
    // Creates a file based on the path using a url. Data is created for nil checker
    NSURL *fileURL = [ThemeHandler getZipForRAF:rafItem] ? [ThemeHandler getZipForRAF:rafItem] : nil;
    NSData *testData = [NSData dataWithContentsOfURL:fileURL];
    
    // If there is no fileURL from a previous RAF, we create one now
    if (!testData) {
        [ThemeHandler packageZipForRAF:rafItem];
        fileURL = [ThemeHandler getZipForRAF:rafItem];
    }

    // Shares using a uiactivityviewcontroller that allows a zip file
    NSString *imageName =  rafItem.imageFilePath != nil && ![rafItem.imageFilePath isEqualToString:@""] ? [NSString stringWithFormat:@"%@.png", rafItem.imageFilePath] : nil;
    [UIActivityViewController shareZip:fileURL withMessage:[FileWriter readMeForRequest:ReadmeTypeRAF containsImage:imageName] subject:@"Ambassador RAF Integration Implementation" forPresenter:self withCompletion:^(NSString * _Nullable activityType, BOOL completed) {
        // Once the share activity has been dismissed, we stop showing the spinner
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shareCellIndex inSection:0];
        RAFCell *cell = [self.rafTable cellForRowAtIndexPath:indexPath];
        [cell stopSpinner];
    }];
}

@end
