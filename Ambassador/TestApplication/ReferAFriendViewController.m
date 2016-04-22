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
    // Creates a new directiry in the documents folder
    NSString *filePath = [[FileWriter documentsPath] stringByAppendingPathComponent:@"ambassador-raf.zip"];
    
    // Creates an array of files for the zip file
    NSMutableArray *entriesArray = [[NSMutableArray alloc] initWithObjects:[self getObjcFile:rafItem], [self getSwiftFile:rafItem], [self getPlist:rafItem],
                                    [self getJavaFile:rafItem], [self getJavaXMLFile:rafItem], nil];
    
    // Checks if there is an image tied to the RAF, and includes it if so
    if ([self getThemeImage:rafItem]) { [entriesArray addObject:[self getThemeImage:rafItem]]; }
    
    // Creates a new zip file containing all different files
    ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
    [newArchive updateEntries:entriesArray error:nil];
    
    // Creates a file based on the path using a url
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    // Shares using a uiactivityviewcontroller that allows a zip file
    [UIActivityViewController shareZip:fileURL withMessage:[FileWriter readmeForRAF] subject:@"Ambassador RAF Theme" forPresenter:self];
}

- (ZZArchiveEntry *)getObjcFile:(RAFItem *)rafItem {
    NSString *objcLine = [NSString stringWithFormat:@"    [AmbassadorSDK presentRAFForCampaign:@\"%@\" FromViewController:self withThemePlist:@\"%@\"];\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *objcFile = [FileWriter objcViewControllerWithInsert:objcLine];
    
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ViewControllerTest.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objcFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

- (ZZArchiveEntry *)getSwiftFile:(RAFItem *)rafItem {
    NSString *swiftLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAFForCampaign(\"%@\", fromViewController: self, withThemePlist: \"%@\")\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *swiftFile = [FileWriter swiftViewControllerWithInsert:swiftLine];
    
    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ViewControllerTest.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

- (ZZArchiveEntry *)getPlist:(RAFItem *)rafItem {
    NSString *plistPath = [ThemeHandler getDocumentsPathWithName:rafItem.plistFullName];
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", rafItem.rafName];
    
    ZZArchiveEntry *plistEntry = [ZZArchiveEntry archiveEntryWithFileName:plistName compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [NSData dataWithContentsOfFile:plistPath];
    }];
    
    return plistEntry;
}

- (ZZArchiveEntry *)getJavaFile:(RAFItem *)rafItem {
    NSString *javaLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAF(this, \"%@\", \"ambassador-raf.xml\");\n", rafItem.campaign.campID];
    NSString *javaFile = [FileWriter javaActivityWithInsert:javaLine];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (ZZArchiveEntry *)getJavaXMLFile:(RAFItem *)rafItem {
    // If the RAF was created before android export was included, we need to generate the xml here
    if (!rafItem.xmlFileData) { [rafItem generateXMLFromPlist:rafItem.plistDict]; }
    
    ZZArchiveEntry *xmlEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ambassador-raf.xml" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return rafItem.xmlFileData;
    }];
    
    return xmlEntry;
}

- (ZZArchiveEntry *)getThemeImage:(RAFItem *)rafItem {
    UIImage *rafImage = [ThemeHandler getImageForRAF:rafItem];
    NSData *imageAttachmentData =  UIImagePNGRepresentation(rafImage);
    NSString *imageName = [NSString stringWithFormat:@"%@.png", rafItem.imageFilePath];
    
    if (!imageAttachmentData) { return nil; }
    
    ZZArchiveEntry *imageEntry = [ZZArchiveEntry archiveEntryWithFileName:imageName compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return imageAttachmentData;
    }];
    
    return imageEntry;
}

@end
