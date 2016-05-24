//
//  ViewController.m
//  TestApplication
//
//  Created by Diplomat on 9/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "IdentifyViewController.h"
#import <Ambassador/Ambassador.h>
#import "DefaultsHandler.h"
#import "AmbassadorLoginViewController.h"
#import "Validator.h"
#import "ValuesHandler.h"
#import "FileWriter.h"
#import <ZipZap/ZipZap.h>
#import "UIActivityViewController+ZipShare.h"
#import "CampaignObject.h"
#import "CampaignListController.h"
#import "SlidingView.h"

@interface IdentifyViewController () <AMBWelcomeScreenDelegate, CampaignListDelegate, UITextFieldDelegate, SlidingViewDatasource>

// IBOutlets
@property (nonatomic, weak) IBOutlet UIButton *btnSubmit;
@property (nonatomic, weak) IBOutlet UITextField *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField *tfFirstName;
@property (nonatomic, weak) IBOutlet UITextField *tfLastName;
@property (nonatomic, weak) IBOutlet UITextField *tfCompany;
@property (nonatomic, weak) IBOutlet UITextField *tfPhone;
@property (nonatomic, weak) IBOutlet UITextField *tfStreet;
@property (nonatomic, weak) IBOutlet UITextField *tfCity;
@property (nonatomic, weak) IBOutlet UITextField *tfState;
@property (nonatomic, weak) IBOutlet UITextField *tfZip;
@property (nonatomic, weak) IBOutlet UITextField *tfCountry;
@property (nonatomic, weak) IBOutlet UITextField *tfCampaign;
@property (nonatomic, weak) IBOutlet UISwitch *swtEnroll;
@property (nonatomic, weak) IBOutlet UIView *imageBGView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet SlidingView *enrollSlider;

// Private properties
@property (nonatomic, strong) NSString *codeExportString;
@property (nonatomic, strong) CampaignObject *selectedCampaign;
@property (nonatomic, strong) UITextField *selectedTextField;

@end


@implementation IdentifyViewController

CGFloat identifyOffset;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpTheme];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.title = @"Identify";
    [self addExportButton];
    [self registerForKeyboardNotificaitons];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Actions

- (IBAction)submitTapped:(id)sender {
    [self identify];
    [self.tfEmail resignFirstResponder];
}

// Action that happens when 'Done' is clicked for certian keyboards
- (void)doneClicked:(id)sender {
    [self.view endEditing:YES];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.tfCampaign]) {
        // Show Campaign list VC
        CampaignListController *campaignList = [[CampaignListController alloc] init];
        campaignList.delegate = self;
        
        // Reason for presentin with tabBarController.parentController is so that the list covers the navBAR
        [self.tabBarController.parentViewController presentViewController:campaignList animated:YES completion:nil];
        
        return NO;
    }
    
    self.selectedTextField = textField;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - WelcomeScreen Delegate

- (void)welcomeScreenActionButtonPressed:(UIButton *)actionButton {
    UIAlertView *actionAlert = [[UIAlertView alloc] initWithTitle:@"Action Button" message:@"You pressed the action button on the welcome screen" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [actionAlert show];
}

- (void)welcomeScreenLinkPressedAtIndex:(NSInteger)linkIndex {
    UIAlertView *linkAlert = [[UIAlertView alloc] initWithTitle:@"Link Tapped" message:[NSString stringWithFormat:@"You tapped a link at index %li", (long)linkIndex] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [linkAlert show];
}


#pragma mark - Keyboard Listener

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    // Saves where the scrollview was currently at before scrolling
    identifyOffset = self.scrollView.contentOffset.y;
    
    // Grabs the keyboard's dimensions
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.selectedTextField.frame.origin.y + self.selectedTextField.superview.frame.origin.y;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    CGFloat newY = keyboardFrame.size.height - difference;
    
    // Makes sure the textfield is not above the keyboard already
    if (newY > 0 && newY > identifyOffset) {
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}


#pragma mark - Campaign List Delegate

- (void)campaignListCampaignChosen:(CampaignObject *)campaignObject {
    self.tfCampaign.text = campaignObject.name;
    self.selectedCampaign = campaignObject;
}


#pragma mark - Sliding View Datasource

- (NSInteger)slidingViewExpandedHeight:(SlidingView *)slidingView {
    return 85;
}

- (NSInteger)slidingViewCollapsedHeight:(SlidingView *)slidingView {
    return 35;
}


#pragma mark - UI Functions

- (void)setUpTheme {
    // TextFields
    self.tfEmail.tintColor = self.btnSubmit.backgroundColor;
    
    // Sets padding for text/placeholder text
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.tfEmail.leftView = paddingView;
    self.tfEmail.leftViewMode = UITextFieldViewModeAlways;
    
    // Login Button
    self.btnSubmit.layer.cornerRadius = 5;
    
    // Images
    self.imageBGView.layer.cornerRadius = 5;
    
    // Adds done button to keyboard
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.tfZip.inputAccessoryView = keyboardDoneButtonView;
    self.tfPhone.inputAccessoryView = keyboardDoneButtonView;
}

- (void)addExportButton {
    UIBarButtonItem *btnExport = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exportIconSm"] style:UIBarButtonItemStylePlain target:self action:@selector(exportCode)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnExport;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Helper Functions

- (void)identify {
    // Grabs strings to pass to in Identify call
    NSString *email = self.tfEmail.text;
    
    // Checks to make sure that a valid email is passed before identifying
    if ([Validator isValidEmail:email]) {
        // Creates 'traits' dictionary for identify call
        NSDictionary *traitsDict = @{@"email" : self.tfEmail.text,
                                     @"firstName" : self.tfFirstName.text,
                                     @"lastName" : self.tfLastName.text,
                                     @"company" : self.tfCompany.text,
                                     @"phone" : self.tfPhone.text,
                                     @"address" : @{
                                         @"street" : self.tfStreet.text,
                                         @"city" : self.tfCity.text,
                                         @"state" : self.tfState.text,
                                         @"postalCode" : self.tfZip.text,
                                         @"country" : self.tfCountry.text}
                                     };
        
        // Creates options to auto-enroll user if campaign is selected and the switch is on
        NSDictionary *optionsDict = self.selectedCampaign && self.swtEnroll.isOn ? @{ @"campaign" : self.selectedCampaign.campID } : nil;
        
        // Call identify
        [AmbassadorSDK identifyWithUserID:@"0" traits:traitsDict options:optionsDict];
        
        NSLog(@"Traits Dict = %@, Options Dict = %@", traitsDict, optionsDict);
        
        // Create an identify success message
        NSString *confirmationMessage = [NSString stringWithFormat:@"You have succesfully identified as %@! You can now track conversion events and create commissions!", email];
        UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:@"Great!" message:confirmationMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [confirmationAlert show];
        
        return;
    }
    
    [self showValidationError:@"identifying"];
    
}

- (void)exportCode {
    [self.tfEmail resignFirstResponder];
    NSString *email = self.tfEmail.text;
    
    if ([Validator isValidEmail:email]) {        
        // Creates a new directiry in the documents folder
        NSString *filePath = [[FileWriter documentsPath] stringByAppendingPathComponent:@"ambassador-identify.zip"];
        
        // Creates a new zip file containing all different files
        ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
        [newArchive updateEntries:@[[self getObjectiveFile:email], [self getSwiftFile:email], [self getJavaFile:email]] error:nil];
        
        // Creates a url that returns an actual file
        NSURL *fileurl = [NSURL fileURLWithPath:filePath];
        
        // Shows a share sheet with the zip file attached
        [UIActivityViewController shareZip:fileurl withMessage:[FileWriter readMeForRequest:ReadmeTypeIdentify containsImage:nil] subject:@"Ambassador Identify Implementation" forPresenter:self];
        
        return;
    }
    
    [self showValidationError:@"exporting"];
}

// Creates an Objective-C App Delegate file
- (ZZArchiveEntry *)getObjectiveFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithEmail:@\"%@\"]; \n\n", email];
    NSString *objectiveCString = [FileWriter objcAppDelegateFileWithInsert:identifyString];
 
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objectiveCString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

// Creates a Swift App Delegate file
- (ZZArchiveEntry *)getSwiftFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithEmail(\"%@\") \n\n", email];
    NSString *swiftString = [FileWriter swiftAppDelegateFileWithInsert:identifyString];

    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

// Creates an example Java file
- (ZZArchiveEntry *)getJavaFile:(NSString *)email {
    // Gets dynamic strings from user's tokens and email input
    NSString *identifyString = [NSString stringWithFormat:@"        AmbassadorSDK.identify(\"%@\"); \n", email];
    NSString *javaString = [FileWriter javaMyApplicationFileWithInsert:identifyString];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (void)showValidationError:(NSString*)action {
    UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [invalidEmailAlert show];
}

@end
