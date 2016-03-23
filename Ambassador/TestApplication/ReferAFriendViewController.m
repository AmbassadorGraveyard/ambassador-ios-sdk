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
#import <MessageUI/MessageUI.h>
#import "ThemeHandler.h"
#import "DefaultsHandler.h"
#import "ValuesHandler.h"

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, RAFCellDelegate, MFMailComposeViewControllerDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UITableView * rafTable;

// Private properties
@property (nonatomic, strong) NSArray * rafArray;
@property (nonatomic) BOOL tableEditing;

@end


@implementation ReferAFriendViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addDefaultIfFirstLaunch];
    self.rafArray = [DefaultsHandler getThemeArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavBarButtons];
}


#pragma mark - Button Actions

- (void)addNewRAF {
    // TODO: Replace with presenting RAF customizer
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Theme" message:@"Type your theme name below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)editRAF {
    self.tableEditing = !self.tableEditing;
    [self setNavBarButtons];
    [self reloadThemesWithFade:NO];
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
    NSString *campaignId = @"1026"; // TEMPORARY
    
    // Gets RAFItem at array and presents a raf using the plist name value
    RAFItem *item = self.rafArray[indexPath.row];
    [AmbassadorSDK presentRAFForCampaign:campaignId FromViewController:self.tabBarController withThemePlist:item.plistFullName];
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


#pragma mark - MFMailComposeVc Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) {
        NSLog(@"Message sent successfully!");
    } else if (result == MFMailComposeResultFailed) {
        NSLog(@"Message failed to send");
    } else {
        NSLog(@"Message was not sent");
    }
}


#pragma mark - RAFCell Delegate

- (void)RAFCellDeleteTappedForRAFItem:(RAFItem *)rafItem {
    [ThemeHandler deleteRafItem:rafItem];
    [self reloadThemesWithFade:YES];
}

- (void)RAFCellExportTappedForRAFItem:(RAFItem *)rafItem {
    [self exportRAFTheme:rafItem];
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
    
    NSString *editTitle = (self.tableEditing && self.rafArray.count >= 1) ? @"Done" : @"Edit";
    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:editTitle style:UIBarButtonItemStylePlain target:self action:@selector(editRAF)];
    self.tabBarController.navigationItem.leftBarButtonItem = btnEdit;
}


#pragma mark - Helper Functions

- (void)reloadThemesWithFade:(BOOL)fade {
    self.rafArray = [DefaultsHandler getThemeArray];
    
    if (self.rafArray.count == 0) {
        [self setNavBarButtons];
        self.tableEditing = NO;
    }
    
    // Only perform fade if deleting or adding
    if (fade) {
        [self.rafTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.rafTable reloadData];
    }
}

- (void)saveNewTheme:(NSString*)themeName {
    // Creates a new RAF item which will be stored to defaults
    RAFItem *item = [[RAFItem alloc] init];
    item.rafName = themeName;
    item.plistFullName = [NSString stringWithFormat:@"AMBTESTAPP%@", themeName];
    item.dateCreated = [NSDate date];
    
    // Saves a new plist item using the RAF item name
    [ThemeHandler saveNewTheme:item];
    
    [self reloadThemesWithFade:YES];
}

- (void)exportRAFTheme:(RAFItem*)rafItem {
    // Gets the path for the plist being exported
    NSString *path = [ThemeHandler getDocumentsPathWithName:rafItem.plistFullName];
    
    // Creates data to be sent as an attachment for the email
    NSData *dataToAttach = [NSData dataWithContentsOfFile:path];
    
    // Creates a code snippet to add in email
    NSString *bodyString = [NSString stringWithFormat:@"Ambassador RAF Code Snippet v%@\n\n%@", [ValuesHandler getVersionNumber], [self getCodeSnippet:rafItem.rafName]];
    
    // Creates a mail compose message to share via email with snippet and plist attachment
    MFMailComposeViewController *mailVc = [[MFMailComposeViewController alloc] init];
    mailVc.mailComposeDelegate = self;
    [mailVc addAttachmentData:dataToAttach mimeType:@"application/plist" fileName:[NSString stringWithFormat:@"%@.plist", rafItem.rafName]];
    [mailVc setSubject:@"Ambassador Theme Plist"];
    [mailVc setMessageBody:bodyString isHTML:NO];
    
    [self presentViewController:mailVc animated:YES completion:nil];
}

- (NSString*)getCodeSnippet:(NSString*)rafName {
    // TODO: Get campaign id from user on RAF page present
    NSString *campID = @"1026"; // Temp
    
    // Creates Obj-c snippet
    NSString *objcHeaderString = @"Objective-C \n";
    NSString *objcRAFSnippet = [NSString stringWithFormat:@"[AmbassadorSDK presentRAFForCampaign:%@ FromViewController:self withThemePlist:@\"%@\"];", campID, rafName];
    NSString *fullObjc = [NSString stringWithFormat:@"%@\n%@", objcHeaderString, objcRAFSnippet];
    
    // Creates Swift snippet
    NSString *swiftHeaderString = @"Swift \n";
    NSString *swiftRAFSnippet = [NSString stringWithFormat:@"AmbassadorSDK.presentRAFForCampaign(%@, fromViewController: self, withThemePlist: \"%@\")", campID, rafName];
    NSString *fullSwift = [NSString stringWithFormat:@"%@\n%@", swiftHeaderString, swiftRAFSnippet];
    
    return [NSString stringWithFormat:@"%@\n\n\n%@", fullObjc, fullSwift];
}

- (void)addDefaultIfFirstLaunch {
    // Adds a default RAF if one has not already been created
    if (![DefaultsHandler hasAddedDefault]) {
        [self saveNewTheme:@"Ambassador Default RAF"];
        [DefaultsHandler setAddedDefaultRAFTrue];
    }
}

@end
