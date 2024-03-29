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
#import "AMBUtilities.h"
#import "UIAlertController+CancelAlertController.h"

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
@property (nonatomic, weak) IBOutlet UITextField *tfUID;
@property (nonatomic, weak) IBOutlet UISwitch *swtEnroll;
@property (nonatomic, weak) IBOutlet UIView *imageBGView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet SlidingView *enrollSlider;
@property (weak, nonatomic) IBOutlet UISwitch *sandboxSwitch;


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
    UIAlertController *actionAlert = [UIAlertController cancelAlertWithTitle:@"Action Button" message:@"You pressed the action button on the welcome screen" cancelMessage:@"Okay"];
    [self presentViewController:actionAlert animated:YES completion:nil];
}

- (void)welcomeScreenLinkPressedAtIndex:(NSInteger)linkIndex {
    UIAlertController *linkAlert = [UIAlertController cancelAlertWithTitle:@"Link Tapped" message:[NSString stringWithFormat:@"You tapped a link at index %li", (long)linkIndex] cancelMessage:@"Okay"];
    [self presentViewController:linkAlert animated:YES completion:nil];
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
                                     @"sandbox": @([self.sandboxSwitch isOn]),
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
        NSString *enrollCampaign = self.selectedCampaign && self.swtEnroll.isOn ? self.selectedCampaign.campID : nil;
        
        NSString *UIDString = ![AMBUtilities stringIsEmpty:self.tfUID.text] ? self.tfUID.text : nil;
        
        // Call identify
        [AmbassadorSDK identifyWithUserID:UIDString traits:traitsDict autoEnrollCampaign:enrollCampaign completion:^(BOOL success){
            if (success){
                // Create an identify success message
                NSString *confirmationMessage = [NSString stringWithFormat:@"You have succesfully identified as %@! You can now track conversion events and create commissions!", email];
                UIAlertController *confirmationAlert = [UIAlertController cancelAlertWithTitle:@"Great!" message:confirmationMessage cancelMessage:@"Okay"];
                [self presentViewController:confirmationAlert animated:YES completion:nil];
            }
            else{
                // Create an identify error message
                NSString *confirmationMessage = [NSString stringWithFormat:@"There was an error identifying."];
                UIAlertController *confirmationAlert = [UIAlertController cancelAlertWithTitle:@"Error" message:confirmationMessage cancelMessage:@"Okay"];
                [self presentViewController:confirmationAlert animated:YES completion:nil];
            }
            
        }];
        
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
    // Creates traits dictionary
    NSMutableString *traitsDictString = [[NSMutableString alloc] init];
    [traitsDictString appendString:@"    // Create dictionary for user traits\n"];
    [traitsDictString appendString:[NSString stringWithFormat:@"    NSDictionary *traitsDict = @{\n%@@\"email\" : @\"%@\"", [self tabSpace], email]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"firstName\" : @\"%@\"", [self tabSpace], self.tfFirstName.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"lastName\" : @\"%@\"", [self tabSpace], self.tfLastName.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfCompany.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"company\" : @\"%@\"", [self tabSpace], self.tfCompany.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfPhone.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"phone\" : @\"%@\"", [self tabSpace], self.tfPhone.text]];
    }
    if ([self.sandboxSwitch isOn]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"sandbox\" : @YES", [self tabSpace]]];
    }
    
    BOOL addressFilledOut = ![AMBUtilities stringIsEmpty:self.tfStreet.text] || ![AMBUtilities stringIsEmpty:self.tfCity.text] || ![AMBUtilities stringIsEmpty:self.tfState.text] || ![AMBUtilities stringIsEmpty:self.tfZip.text] || ![AMBUtilities stringIsEmpty:self.tfCountry.text];
    
    // Checks if any section of the address is filled out
    if (addressFilledOut) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@@\"address\" : @{\n", [self tabSpace]]];
    }
    
    BOOL hasAddressFields = NO;
    
    // Formats the address portion of traits if provided
    if (![AMBUtilities stringIsEmpty:self.tfStreet.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@@\"street\" : @\"%@\"", [self largeTabSpace], self.tfStreet.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfCity.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@@\"city\" : @\"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpace], self.tfCity.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfState.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@@\"state\" : @\"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpace], self.tfState.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfZip.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@@\"postalCode\" : @\"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpace], self.tfZip.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfCountry.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@@\"country\" : @\"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpace], self.tfCountry.text]];
    }
    
    if (addressFilledOut) {
        [traitsDictString appendString:[NSString stringWithFormat:@"\n%@}", [self largeTabSpace]]];
    }
    
    [traitsDictString appendString:[NSString stringWithFormat:@"\n%@};\n\n", [self tabSpace]]];
    
    // Creates the correct identify string based on options dict being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"nil" : [NSString stringWithFormat:@"@\"%@\"", self.tfUID.text];
    NSString *identifyString = (self.swtEnroll.isOn && self.selectedCampaign) ? [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithUserID:%@ traits:traitsDict autoEnrollCampaign:@\"%@\"];\n", userIdString, self.selectedCampaign.campID] :
                                                    [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithUserID:%@ traits:traitsDict];\n", userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *fullString = [[NSMutableString alloc] init];
    if (traitsDictString) { [fullString appendString:traitsDictString]; }
    [fullString appendString:identifyString];
    
    // Gets dynamic strings from user's tokens and email input
    NSString *objectiveCString = [FileWriter objcAppDelegateFileWithInsert:fullString];
 
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objectiveCString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

// Creates a Swift App Delegate file
- (ZZArchiveEntry *)getSwiftFile:(NSString *)email {
    // Creates traits dictionary
    NSMutableString *traitsDictString = [[NSMutableString alloc] init];
    [traitsDictString appendString:@"        // Create dictionary for user traits\n"];
    [traitsDictString appendString:[NSString stringWithFormat:@"        var traitsDict = [\n%@\"email\" : \"%@\"", [self tabSpaceSwift], email]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"firstName\" : \"%@\"", [self tabSpaceSwift], self.tfFirstName.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"lastName\" : \"%@\"", [self tabSpaceSwift], self.tfLastName.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfCompany.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"company\" : \"%@\"", [self tabSpaceSwift], self.tfCompany.text]];
    }
    if (![AMBUtilities stringIsEmpty:self.tfPhone.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"phone\" : \"%@\"", [self tabSpaceSwift], self.tfPhone.text]];
    }
    if ([self.sandboxSwitch isOn]) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"sandbox\" : \"true\"", [self tabSpaceSwift]]];
    }
    
    BOOL addressFilledOut = ![AMBUtilities stringIsEmpty:self.tfStreet.text] || ![AMBUtilities stringIsEmpty:self.tfCity.text] || ![AMBUtilities stringIsEmpty:self.tfState.text] || ![AMBUtilities stringIsEmpty:self.tfZip.text] || ![AMBUtilities stringIsEmpty:self.tfCountry.text];
    
    // Checks if any section of the address is filled out
    if (addressFilledOut) {
        [traitsDictString appendString:[NSString stringWithFormat:@",\n%@\"address\" : [\n", [self tabSpaceSwift]]];
    }
    
    BOOL hasAddressFields = NO;
    
    // Formats the address portion of traits if provided
    if (![AMBUtilities stringIsEmpty:self.tfStreet.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@\"street\" : \"%@\"", [self largeTabSpaceSwift], self.tfStreet.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfCity.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@\"city\" : \"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpaceSwift], self.tfCity.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfState.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@\"state\" : \"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpaceSwift], self.tfState.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfZip.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@\"postalCode\" : \"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpaceSwift], self.tfZip.text]];
        hasAddressFields = YES;
    }
    if (![AMBUtilities stringIsEmpty:self.tfCountry.text]) {
        [traitsDictString appendString:[NSString stringWithFormat:@"%@%@\"country\" : \"%@\"", hasAddressFields ? @",\n" : @"", [self largeTabSpaceSwift], self.tfCountry.text]];
    }
    
    if (addressFilledOut) {
        [traitsDictString appendString:[NSString stringWithFormat:@"\n%@]", [self tabSpaceSwift]]];
    }
    
    [traitsDictString appendString:[NSString stringWithFormat:@"\n        ]\n\n"]];
    
    // Creates the correct identify string based on options dict being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"nil" : [NSString stringWithFormat:@"\"%@\"", self.tfUID.text];
    NSString *identifyString = (self.swtEnroll.isOn && self.selectedCampaign) ? [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithUserID(%@, traits: infoDict, autoEnrollCampaign: \"%@\")\n", userIdString, self.selectedCampaign.campID] :
                                                    [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithUserID(%@, traits: infoDict)\n", userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *fullString = [[NSMutableString alloc] init];
    if (traitsDictString) { [fullString appendString:traitsDictString]; }
    [fullString appendString:identifyString];
    
    
    // Gets dynamic strings from user's tokens and email input
    NSString *swiftString = [FileWriter swiftAppDelegateFileWithInsert:fullString];

    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

// Creates an example Java file
- (ZZArchiveEntry *)getJavaFile:(NSString *)email {
    NSString *spacing = @"        ";
    NSMutableString *traitsString = [[NSMutableString alloc] initWithFormat:@"%@// Create bundle with traits about user\n", spacing];
    [traitsString appendFormat:@"%@Bundle traits = new Bundle();\n", spacing];
    [traitsString appendFormat:@"%@traits.putString(\"email\", \"%@\");\n", spacing, self.tfEmail.text];
    
    // If the optional forms are filled out, we add them to the snippet
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) {
        [traitsString appendFormat:@"%@traits.putString(\"firstName\", \"%@\");\n", spacing, self.tfFirstName.text];
    }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) {
        [traitsString appendFormat:@"%@traits.putString(\"lastName\", \"%@\");\n", spacing, self.tfLastName.text];
    }
    if (![AMBUtilities stringIsEmpty:self.tfCompany.text]) {
        [traitsString appendFormat:@"%@traits.putString(\"company\", \"%@\");\n", spacing, self.tfCompany.text];
    }
    if (![AMBUtilities stringIsEmpty:self.tfPhone.text]) {
        [traitsString appendFormat:@"%@traits.putString(\"phone\", \"%@\");\n", spacing, self.tfPhone.text];
    }
    if ([self.sandboxSwitch isOn]) {
        [traitsString appendFormat:@"%@traits.putString(\"sandbox\", 1);\n\n", spacing];
    }
    
    // Checks if any address fields have been filled out before adding the address bundle code
    if (![AMBUtilities stringIsEmpty:self.tfStreet.text] || ![AMBUtilities stringIsEmpty:self.tfCity.text] || ![AMBUtilities stringIsEmpty:self.tfState.text] || ![AMBUtilities stringIsEmpty:self.tfZip.text] || ![AMBUtilities stringIsEmpty:self.tfCountry.text]) {
        [traitsString appendFormat:@"%@// Create an address bundle to go inside of traits bundle\n", spacing];
        [traitsString appendFormat:@"%@Bundle address = new Bundle();\n", spacing];
        
        // Go through each address field and add them to the snippet
        if (![AMBUtilities stringIsEmpty:self.tfStreet.text]) {
            [traitsString appendFormat:@"%@address.putString(\"street\", \"%@\");\n", spacing, self.tfStreet.text];
        }
        if (![AMBUtilities stringIsEmpty:self.tfCity.text]) {
            [traitsString appendFormat:@"%@address.putString(\"city\", \"%@\");\n", spacing, self.tfCity.text];
        }
        if (![AMBUtilities stringIsEmpty:self.tfState.text]) {
            [traitsString appendFormat:@"%@address.putString(\"state\", \"%@\");\n", spacing, self.tfState.text];
        }
        if (![AMBUtilities stringIsEmpty:self.tfZip.text]) {
            [traitsString appendFormat:@"%@address.putString(\"postalCode\", \"%@\");\n", spacing, self.tfZip.text];
        }
        if (![AMBUtilities stringIsEmpty:self.tfCountry.text]) {
            [traitsString appendFormat:@"%@address.putString(\"country\", \"%@\");\n", spacing, self.tfCountry.text];
        }
        
        // Add address bundle in traits
        [traitsString appendFormat:@"%@traits.putBundle(\"address\", address);\n\n", spacing];
    }
    
    NSMutableString *optionsString = nil;
    if (self.swtEnroll.isOn && self.selectedCampaign) {
        optionsString = [[NSMutableString alloc] initWithFormat:@"%@// Create bundle with option to auto-enroll user in campaign\n", spacing];
        [optionsString appendFormat:@"%@Bundle options = new Bundle();\n", spacing];
        [optionsString appendFormat:@"%@options.putString(\"campaign\", \"%@\");\n\n", spacing, self.selectedCampaign.campID];
    }
    
    // Creates the correct identify string based on options being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"null" : [NSString stringWithFormat:@"\"%@\"", self.tfUID.text];
    NSString *identifyString = (optionsString) ? [NSString stringWithFormat:@"%@AmbassadorSDK.identify(%@, traits, options);\n", spacing, userIdString] :
                                                [NSString stringWithFormat:@"%@AmbassadorSDK.identify(%@, traits, null);\n", spacing, userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *fullString = [[NSMutableString alloc] init];
    if (traitsString) { [fullString appendString:traitsString]; }
    if (optionsString) { [fullString appendString:optionsString]; }
    [fullString appendString:identifyString];

    NSString *javaString = [FileWriter javaMyApplicationFileWithInsert:fullString];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (void)showValidationError:(NSString*)action {
    UIAlertController *invalidEmailAlert = [UIAlertController cancelAlertWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address before %@.", action] cancelMessage:@"Okay"];
    [self presentViewController:invalidEmailAlert animated:YES completion:nil];
}

- (NSString *)tabSpace {
    return @"                                 ";
}

- (NSString *)largeTabSpace {
    return @"                                     ";
}

- (NSString *)tabSpaceSwift {
    return @"            ";
}

- (NSString *)largeTabSpaceSwift {
    return @"                ";
}

@end
