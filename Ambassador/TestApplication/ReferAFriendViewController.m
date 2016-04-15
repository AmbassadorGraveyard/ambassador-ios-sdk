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
#import "RAFCustomizer.h"
#import "FileWriter.h"

@interface ReferAFriendViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, RAFCellDelegate, MFMailComposeViewControllerDelegate, RAFCustomizerDelegate>

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
    NSString *confirmationString = [NSString stringWithFormat:@"%@ will be permanently deleted.", rafItem.rafName];
    
    UIAlertView *deleteConfirmation = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:confirmationString delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [deleteConfirmation show];
    
    // Gets rafItem to delete
    itemToDelete = rafItem;
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
    // Changes button title based on editing state
    NSString *editTitle = (self.tableEditing && self.rafArray.count >= 1) ? @"Done" : @"Edit";
    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:editTitle style:UIBarButtonItemStylePlain target:self action:@selector(editRAF)];
    self.tabBarController.navigationItem.leftBarButtonItem = btnEdit;
    
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

- (void)saveNewTheme:(RAFItem*)saveItem {
    // Saves a new plist item using the RAF item name and reloads table
    [ThemeHandler saveTheme:saveItem];
    [self reloadThemesWithFade:YES];
}

- (void)exportRAFTheme:(RAFItem*)rafItem {
    // Gets the path for the plist being exported
    NSString *plistPath = [ThemeHandler getDocumentsPathWithName:rafItem.plistFullName];
    UIImage *rafImage = [ThemeHandler getImageForRAF:rafItem];
    
    // Creates data to be sent as an attachment for the email
    NSData *plistAttachmentData = [NSData dataWithContentsOfFile:plistPath];
    NSData *imageAttachmentData =  UIImagePNGRepresentation(rafImage);
    
    // Creates a mail compose message to share via email with snippet and file attachments
    MFMailComposeViewController *mailVc = [[MFMailComposeViewController alloc] init];
    mailVc.mailComposeDelegate = self;
    [mailVc addAttachmentData:[self getReadme] mimeType:@"application/txt" fileName:@"README.md"];
    [mailVc addAttachmentData:plistAttachmentData mimeType:@"application/plist" fileName:[NSString stringWithFormat:@"%@.plist", rafItem.rafName]];
    [mailVc addAttachmentData:[self getObjcFile:rafItem] mimeType:@"application/txt" fileName:@"ViewControllerTest.m"];
    [mailVc addAttachmentData:[self getSwiftFile:rafItem] mimeType:@"application/txt" fileName:@"ViewControllerTest.swift"];
    
    if (rafItem.xmlFileData) {
        [mailVc addAttachmentData:rafItem.xmlFileData mimeType:@"application/txt" fileName:@"ambassador-raf.xml"];
    }
    
    [mailVc addAttachmentData:[self getJavaFile:rafItem] mimeType:@"application/txt" fileName:@"MyActivity.java"];
    
    // Checks if RAF contains an image
    if (imageAttachmentData) { [mailVc addAttachmentData:imageAttachmentData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png", rafItem.rafName]]; }
    
    [mailVc setSubject:@"Ambassador RAF Theme"];
    
    [self presentViewController:mailVc animated:YES completion:nil];
}

- (NSString*)getCodeSnippet:(RAFItem*)rafItem {
    NSString *campID = rafItem.campaign.campID;
    
    // Creates Obj-c snippet
    NSString *objcHeaderString = @"Objective-C \n";
    NSString *objcRAFSnippet = [NSString stringWithFormat:@"[AmbassadorSDK presentRAFForCampaign:@\"%@\" FromViewController:self withThemePlist:@\"%@\"];", campID, rafItem.rafName];
    NSString *fullObjc = [NSString stringWithFormat:@"%@\n%@", objcHeaderString, objcRAFSnippet];
    
    // Creates Swift snippet
    NSString *swiftHeaderString = @"Swift \n";
    NSString *swiftRAFSnippet = [NSString stringWithFormat:@"AmbassadorSDK.presentRAFForCampaign(\"%@\", fromViewController: self, withThemePlist: \"%@\")", campID, rafItem.rafName];
    NSString *fullSwift = [NSString stringWithFormat:@"%@\n%@", swiftHeaderString, swiftRAFSnippet];
    
    return [NSString stringWithFormat:@"%@\n\n\n%@", fullObjc, fullSwift];
}

- (NSData *)getObjcFile:(RAFItem *)rafItem {
    NSString *objcLine = [NSString stringWithFormat:@"    [AmbassadorSDK presentRAFForCampaign:@\"%@\" FromViewController:self withThemePlist:@\"%@\"];\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *objcFile = [FileWriter objcViewControllerWithInsert:objcLine];
    
    return [objcFile dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getSwiftFile:(RAFItem *)rafItem {
    NSString *swiftLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAFForCampaign(\"%@\", fromViewController: self, withThemePlist: \"%@\")\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *swiftFile = [FileWriter swiftViewControllerWithInsert:swiftLine];
    
    return [swiftFile dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getJavaFile:(RAFItem *)rafItem {
    NSString *javaLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAF(this, \"%@\", \"ambassador-raf.xml\");\n", rafItem.campaign.campID];
    NSString *javaFile = [FileWriter javaActivityWithInsert:javaLine];
    
    return [javaFile dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getReadme {
    NSString *readmeLine = [FileWriter readmeForRAF];
    return [readmeLine dataUsingEncoding:NSUTF8StringEncoding];
}

@end
