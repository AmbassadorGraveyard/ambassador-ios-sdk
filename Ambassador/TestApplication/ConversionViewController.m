//
//  SignUpViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/11/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ConversionViewController.h"
#import <Ambassador/Ambassador.h>
#import "Validator.h"
#import "ValuesHandler.h"
#import "AMBConversionParameter_Internal.h"
#import "LoadingScreen.h"
#import "AMBUtilities.h"
#import "DefaultsHandler.h"
#import "AMBValues.h"
#import "FileWriter.h"
#import <ZipZap/ZipZap.h>
#import "UIActivityViewController+ZipShare.h"
#import "SlidingView.h"
#import "CampaignListController.h"
#import "GroupListViewController.h"
#import "GroupObject.h"

@interface ConversionViewController () <UITextFieldDelegate, SlidingViewDatasource, SlidingViewDelegate, CampaignListDelegate, GroupListDelegate>

@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UISwitch * swtApproved;
@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) IBOutlet UITextField * tfRefEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfRevAmt;
@property (nonatomic, strong) IBOutlet UITextField * tfCampID;
@property (nonatomic, strong) IBOutlet UITextField * tfReferrerEmail;

// Optional Param fields
@property (nonatomic, strong) IBOutlet UITextField * tfGroupID;
@property (nonatomic, strong) IBOutlet UITextField * tfFirstName;
@property (nonatomic, strong) IBOutlet UITextField * tfLastName;
@property (nonatomic, strong) IBOutlet UITextField * tfUID;
@property (nonatomic, strong) IBOutlet UITextField * tfCustom1;
@property (nonatomic, strong) IBOutlet UITextField * tfCustom2;
@property (nonatomic, strong) IBOutlet UITextField * tfCustom3;
@property (nonatomic, strong) IBOutlet UITextField * tfTransactionUID;
@property (nonatomic, strong) IBOutlet UITextField * tfEventData1;
@property (nonatomic, strong) IBOutlet UITextField * tfEventData2;
@property (nonatomic, strong) IBOutlet UITextField * tfEventData3;
@property (nonatomic, strong) IBOutlet UISwitch * swtEmailNewAmbassador;
@property (nonatomic, strong) IBOutlet UISwitch * swtAutoCreate;
@property (nonatomic, strong) IBOutlet UISwitch * swtDeactivateNewAmbassador;

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet SlidingView * svAmbassador;
@property (nonatomic, strong) IBOutlet SlidingView * svCustomer;
@property (nonatomic, strong) IBOutlet SlidingView * svCommission;
@property (nonatomic, weak) IBOutlet SlidingView * svEnroll;

// Private properties
@property (nonatomic, strong) UITextField * selectedTextField;
@property (nonatomic, strong) CampaignObject * selectedCampaign;

@end


@implementation ConversionViewController

CGFloat currentOffset;

// Sliding view heights
NSInteger AMBASSADOR_SLIDING_HEIGHT = 83;
NSInteger CUSTOMER_ORIGINAL_SLIDING_HEIGHT = 435;
NSInteger CUSTOMER_NEW_SLIDING_HEIGHT = 538;
NSInteger COMMISION_SLIDING_HEIGHT = 388;
NSInteger ENROLL_SLIDING_HEIGHT = 123;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
    [self setupSlidingViews];
    
    // TEMPORARY-- Sets up 3 second press gesture to test out the 'Track' function
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(testTrack:)];
    longPress.minimumPressDuration = 3;
    [self.btnSubmit addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.title = @"Conversion";
    [self registerForKeyboardNotificaitons];
    [self addConversionExportButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Unregisters view for keyboard notificaitons
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - IBAction

- (IBAction)submitTapped:(id)sender {
    [self.view endEditing:YES];
    [self performConversionActionWithShortCode];
}

- (void)doneClicked:(id)sender {
    [self.view endEditing:YES];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // If campaign textField gains focus
    if ([textField isEqual:self.tfCampID]) {
        [self.selectedTextField resignFirstResponder];
        
        // Show Campaign list VC
        CampaignListController *campaignList = [[CampaignListController alloc] init];
        campaignList.delegate = self;
        
        // Reason for presentin with tabBarController.parentController is so that the list covers the navBAR
        [self.tabBarController.parentViewController presentViewController:campaignList animated:YES completion:nil];
        
        return NO;
    }
    
    // If Add to groups textField gains focus
    if ([textField isEqual:self.tfGroupID]) {
        [self.selectedTextField resignFirstResponder];
        
        // Show group list viewController
        GroupListViewController *groupList = [[GroupListViewController alloc] initWithSelectedArray:[self arrayFromGroupsField]];
        groupList.delegate = self;
        
        // Reason for presentin with tabBarController.parentController is so that the list covers the navBAR
        [self.tabBarController.parentViewController presentViewController:groupList animated:YES completion:nil];
        
        return NO;
    }
    
    self.selectedTextField = textField;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Keyboard Listeners

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    // Saves where the scrollview was currently at before scrolling
    currentOffset = self.scrollView.contentOffset.y;
    
    // Grabs the keyboard's dimensions
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.selectedTextField.frame.origin.y + self.selectedTextField.superview.frame.origin.y;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    CGFloat newY = keyboardFrame.size.height - difference;
    
    // Makes sure the textfield is not above the keyboard already
    if (newY > 0 && newY > currentOffset) {
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}


#pragma mark - Sliding View Datasource

- (NSInteger)slidingViewExpandedHeight:(SlidingView *)slidingView {
    if (slidingView == self.svAmbassador) {
        return AMBASSADOR_SLIDING_HEIGHT;
    } else if (slidingView == self.svCustomer) {
        return CUSTOMER_ORIGINAL_SLIDING_HEIGHT;
    } else if (slidingView == self.svCommission) {
        return COMMISION_SLIDING_HEIGHT;
    } else {
        return ENROLL_SLIDING_HEIGHT;
    }
}

- (NSInteger)slidingViewCollapsedHeight:(SlidingView *)slidingView {
    if (slidingView == self.svEnroll) {
        return 32;
    }
    
    return 35;
}


#pragma mark - Sliding View Delegate

- (void)slidingViewExpanded:(SlidingView *)slidingView {
    if (slidingView == self.svEnroll) {
        [self.svCustomer setNewExpandedHeight:CUSTOMER_NEW_SLIDING_HEIGHT];
    }
}

- (void)slidingViewCollapsed:(SlidingView *)slidingView {
    if (slidingView == self.svEnroll) {
        [self.svCustomer setNewExpandedHeight:CUSTOMER_ORIGINAL_SLIDING_HEIGHT];
    }
}


#pragma mark - Campaign List Delegate

- (void)campaignListCampaignChosen:(CampaignObject *)campaignObject {
    self.selectedCampaign = campaignObject;
    self.tfCampID.text = campaignObject.name;
}


#pragma mark - Group List Delegate

- (void)groupListSelectedGroups:(NSArray *)groups {
    NSMutableString *idArrayString = [[NSMutableString alloc] init];
    
    for (NSString *idString in groups) {
        NSString *currentId = [idString isEqual:[groups lastObject]] ? idString : [NSString stringWithFormat:@"%@, ", idString];
        [idArrayString appendString:currentId];
    }
    
    self.tfGroupID.text = idArrayString;
}


#pragma mark - UI Functions

- (void)setUpTheme {
    // Buttons
    self.btnSubmit.layer.cornerRadius = 5;
    
    // Views
    self.imgBGView.layer.cornerRadius = 5;
    
    // TextFields
    self.tfCampID.tintColor = self.btnSubmit.backgroundColor;
    self.tfRefEmail.tintColor = self.btnSubmit.backgroundColor;
    self.tfRevAmt.tintColor = self.btnSubmit.backgroundColor;
    
    // Adds done button to keyboard
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.tfRevAmt.inputAccessoryView = keyboardDoneButtonView;
}

- (void)addConversionExportButton {
    UIBarButtonItem *btnExport = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exportIconSm"] style:UIBarButtonItemStylePlain target:self action:@selector(exportConversionCode)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnExport;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Helper Functions

- (void)getShortCodeAndSubmitForTest:(BOOL)testing {
    // Sets up request
    NSString *urlString = [NSString stringWithFormat:@"urls/?campaign_uid=%@&email=%@", self.selectedCampaign.campID, self.tfReferrerEmail.text];
    
    NSURL *ambassadorURL;
    #if AMBPRODUCTION
        ambassadorURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.getambassador.com/%@",  urlString]];
    #else
        ambassadorURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://dev-ambassador-api.herokuapp.com/%@", urlString]];
    #endif
    
    [LoadingScreen showLoadingScreenForView:self.view];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ambassadorURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"SDKToken %@", [DefaultsHandler getSDKToken]] forHTTPHeaderField:@"Authorization"];
    
    // Makes network call
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [LoadingScreen hideLoadingScreenForView:self.view];
            
        // Get the response code and handle accordingly
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            // Grabs the dictionary returned from the call
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // Checks if the count is greater than zero
            if (returnDict[@"count"] > [NSNumber numberWithInteger:0]) {
                // Grabs the shortcode from the response and makes a conversion call
                NSString *shortCode = [self shortCodeFromDictionary:returnDict];
                
                // If testing, we call the new Track method
                if (testing) {
                    [self performTrackWithShortCode:shortCode];
                    
                // Else, we call the regular RegisterConversion method
                } else {
                    [self registerConversionWithShortCode:shortCode];
                }
            } else {
                UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Conversion Failed" message:@"An ambassador could not be found for the email and campaign provided." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [failAlert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Conversion Failed" message:@"There was an error registering the conversion.  Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }] resume];
}

- (void)registerConversionWithShortCode:(NSString*)shortCode {
    // Gets the conversion object and saves the short code so that the conversion can be registered
    AMBConversionParameters *conversionParameters = [self conversionParameterFromValues];
    [AMBValues setMbsyCookieWithCode:shortCode];
    
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Great!" message:@"You have successfully registered a conversion." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [successAlert show];
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(AMBConversionParameters *conversion, ConversionStatus conversionStatus, NSError *error) {
        NSLog(@"Conversion Object - %@", conversion);
        
        switch (conversionStatus) {
            case ConversionSuccessful:
                NSLog(@"Success!");
                break;
            case ConversionPending:
                NSLog(@"Pending!");
                break;
            case ConversionError:
                NSLog(@"Error :(");
                break;
            default:
                break;
        }
    }];
}

- (void)performConversionActionWithShortCode {
    if (![self invalidFields:YES]) {
        [self getShortCodeAndSubmitForTest:NO];
    }
}

- (void)exportConversionCode {
    if (![self invalidFields:NO]) {
        // Creates a new directiry in the documents folder
        NSString *filePath = [[FileWriter documentsPath] stringByAppendingPathComponent:@"ambassador-conversion.zip"];
        
        // Creates a new zip file containing all different files
        ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
        [newArchive updateEntries:@[[self getObjcFile], [self getSwiftFile], [self getJavaFile]] error:nil];
        
        // Grabs the file using a url to the file path
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        // ActivityViewController category function that shares a zip
        [UIActivityViewController shareZip:fileURL withMessage:[FileWriter readMeForRequest:ReadmeTypeConversion containsImage:nil] subject:@"Ambassador Conversion Implementation" forPresenter:self];
    }
}

- (ZZArchiveEntry *)getObjcFile {
    // Create IDENTIFY part of snippet starting with traits dict
    NSMutableString *traitsDictString = [[NSMutableString alloc] init];
    [traitsDictString appendString:@"    // Create dictionary for user traits\n"];
    [traitsDictString appendString:[NSString stringWithFormat:@"    NSDictionary *traitsDict = @{@\"email\" : @\"%@\",\n", self.tfRefEmail.text]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) { [traitsDictString appendString:[NSString stringWithFormat:@"%@@\"firstName\" : @\"%@\",\n", [self tabSpace], self.tfFirstName.text]]; }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) { [traitsDictString appendString:[NSString stringWithFormat:@"%@@\"lastName\" : @\"%@\",\n", [self tabSpace], self.tfLastName.text]]; }
    if (![AMBUtilities stringIsEmpty:self.tfGroupID.text] && self.swtAutoCreate.isOn) { [traitsDictString appendFormat:@"%@@\"addToGroups\" : @\"%@\",\n", [self tabSpace], self.tfGroupID.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom1.text]) { [traitsDictString appendFormat:@"%@@\"customLabel1\" : @\"%@\",\n", [self tabSpace], self.tfCustom1.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom2.text]) { [traitsDictString appendFormat:@"%@@\"customLabel2\" : @\"%@\",\n", [self tabSpace], self.tfCustom2.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom3.text]) { [traitsDictString appendFormat:@"%@@\"customLabel3\" : @\"%@\",\n", [self tabSpace], self.tfCustom3.text]; }
    [traitsDictString appendString:[NSString stringWithFormat:@"%@};\n\n", [self tabSpace]]];
    
    // Creates options dictionary if switch is on
    NSMutableString *optionsDictString = nil;
    if (self.swtAutoCreate.isOn) {
        optionsDictString = [[NSMutableString alloc] initWithString:@"    // Create dictionary with option to auto-enroll user in campaign\n"];
        [optionsDictString appendString:[NSString stringWithFormat:@"    NSDictionary *identifyOptionsDictionary = @{@\"campaign\" : @\"%@\"};\n\n", self.selectedCampaign.campID]];
    }
    
    // Creates the correct identify string based on options dict being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"nil" : [NSString stringWithFormat:@"@\"%@\"", self.tfUID.text];
    NSString *identifyString = (optionsDictString) ? [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithUserID:%@ traits:traitsDict options:identifyOptionsDictionary];\n", userIdString] :
    [NSString stringWithFormat:@"    [AmbassadorSDK identifyWithUserID:%@ traits:traitsDict options:nil];\n", userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *fullString = [[NSMutableString alloc] init];
    if (traitsDictString) { [fullString appendString:traitsDictString]; }
    if (optionsDictString) { [fullString appendString:optionsDictString]; }
    [fullString appendString:identifyString];
    
    
    /* Create CONVERSION part of snippet */
    NSMutableString *conversionPropertyString = [[NSMutableString alloc] init];
    [conversionPropertyString appendString:@"    // Create dictionary for conversion properties\n"];
    [conversionPropertyString appendString:[NSString stringWithFormat:@"    NSDictionary *propertiesDictionary = @{@\"email\" : @\"%@\",\n", self.tfRefEmail.text]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@@\"campaign\" : @\"%@\",\n", [self tabSpace], self.selectedCampaign.campID]];
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@@\"revenue\" : @%@,\n", [self tabSpace], self.tfRevAmt.text]];
    [conversionPropertyString appendFormat:@"%@@\"commissionApproved\" : @%@\n", [self tabSpace], [self stringForBool:self.swtApproved.isOn forSwift:NO]];
    if (self.swtAutoCreate.isOn) { [conversionPropertyString appendFormat:@"%@@\"emailNewAmbassador\" : @%@,\n", [self tabSpace], [self stringForBool:self.swtEmailNewAmbassador.isOn forSwift:NO]]; }
    if (![AMBUtilities stringIsEmpty:self.tfTransactionUID.text]) { [conversionPropertyString appendFormat:@"%@@\"orderId\" : @\"%@\",\n", [self tabSpace], self.tfTransactionUID.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData1.text]) { [conversionPropertyString appendFormat:@"%@@\"eventData1\" : @\"%@\",\n", [self tabSpace], self.tfEventData1.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData2.text]) { [conversionPropertyString appendFormat:@"%@@\"eventData2\" : @\"%@\",\n", [self tabSpace], self.tfEventData2.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData3.text]) { [conversionPropertyString appendFormat:@"%@@\"eventData3\" : @\"%@\",\n", [self tabSpace], self.tfEventData3.text]; }
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@};\n\n", [self tabSpace]]];
    
    [conversionPropertyString appendString:@"    // Create options dictionary for conversion\n"];
    [conversionPropertyString appendString:@"    NSDictionary *optionsDictionary = @{@\"conversion\" : @YES};\n"];
    
    NSMutableString *conversionString = [[NSMutableString alloc] initWithString:@"    [AmbassadorSDK trackEvent:@\"Event Name\" properties:propertiesDictionary options:optionsDictionary completion:^(AMBConversionParameters *conversion, ConversionStatus conversionStatus, NSError *error) {\n"];
    [conversionString appendFormat:@"%@switch (conversionStatus) {\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionSuccessful:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        NSLog(@\"Success!\");\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break;\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionPending:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        NSLog(@\"Pending!\");\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break;\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionError:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        NSLog(@\"Error!\");\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break;\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    default:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break;\n", [self doubleTab]];
    [conversionString appendFormat:@"%@}\n", [self doubleTab]];
    [conversionString appendString:@"    }];\n"];
    
    // Full identify/conversion string
    NSString *fullConversionString = [NSString stringWithFormat:@"%@\n%@", conversionPropertyString, conversionString];
    
    // Creats app delegate file
    NSString *objcConversion = [NSString stringWithFormat:@"%@\n\n\n%@\n\n", fullString, fullConversionString];
    NSString *objcSnippet = [FileWriter objcAppDelegateFileWithInsert:objcConversion];
    
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objcSnippet dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

- (ZZArchiveEntry *)getSwiftFile {
    // Create IDENTIFY part of snippet starting with traits dict
    NSMutableString *traitsDictString = [[NSMutableString alloc] init];
    [traitsDictString appendString:@"        // Create dictionary for user traits\n"];
    [traitsDictString appendString:[NSString stringWithFormat:@"        let traitsDict = [\"email\" : \"%@\",\n", self.tfRefEmail.text]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) { [traitsDictString appendString:[NSString stringWithFormat:@"%@\"firstName\" : \"%@\",\n", [self tabSpace], self.tfFirstName.text]]; }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) { [traitsDictString appendString:[NSString stringWithFormat:@"%@\"lastName\" : \"%@\",\n", [self tabSpace], self.tfLastName.text]]; }
    if (![AMBUtilities stringIsEmpty:self.tfGroupID.text] && self.swtAutoCreate.isOn) { [traitsDictString appendFormat:@"%@\"addToGroups\" : \"%@\",\n", [self tabSpace], self.tfGroupID.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom1.text]) { [traitsDictString appendFormat:@"%@\"customLabel1\" : \"%@\",\n", [self tabSpace], self.tfCustom1.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom2.text]) { [traitsDictString appendFormat:@"%@\"customLabel2\" : \"%@\",\n", [self tabSpace], self.tfCustom2.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfCustom3.text]) { [traitsDictString appendFormat:@"%@\"customLabel3\" : \"%@\",\n", [self tabSpace], self.tfCustom3.text]; }
    [traitsDictString appendString:[NSString stringWithFormat:@"%@]\n\n", [self tabSpace]]];
    
    // Creates options dictionary if switch is on
    NSMutableString *optionsDictString = nil;
    if (self.swtAutoCreate.isOn) {
        optionsDictString = [[NSMutableString alloc] initWithString:@"        // Create dictionary with option to auto-enroll user in campaign\n"];
        [optionsDictString appendString:[NSString stringWithFormat:@"        let identifyOptionsDictionary = [\"campaign\" : \"%@\"]\n\n", self.selectedCampaign.campID]];
    }
    
    // Creates the correct identify string based on options dict being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"nil" : [NSString stringWithFormat:@"\"%@\"", self.tfUID.text];
    NSString *identifyString = (optionsDictString) ? [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithUserID(%@, traits:traitsDict, options:identifyOptionsDictionary)\n", userIdString] :
                                                    [NSString stringWithFormat:@"        AmbassadorSDK.identifyWithUserID(%@, traits:traitsDict, options:nil)\n", userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *fullString = [[NSMutableString alloc] init];
    if (traitsDictString) { [fullString appendString:traitsDictString]; }
    if (optionsDictString) { [fullString appendString:optionsDictString]; }
    [fullString appendString:identifyString];
    
    
    /* Create CONVERSION part of snippet */
    NSMutableString *conversionPropertyString = [[NSMutableString alloc] init];
    [conversionPropertyString appendString:@"        // Create dictionary for conversion properties\n"];
    [conversionPropertyString appendString:[NSString stringWithFormat:@"        let propertiesDictionary = [\"email\" : \"%@\",\n", self.tfRefEmail.text]];
    
    // Checks all the traits inputs to see if they are filled out and should be added
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@\"campaign\" : \"%@\",\n", [self tabSpace], self.selectedCampaign.campID]];
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@\"revenue\" : %@,\n", [self tabSpace], self.tfRevAmt.text]];
    [conversionPropertyString appendFormat:@"%@\"commissionApproved\" : %@,\n", [self tabSpace], [self stringForBool:self.swtApproved.isOn forSwift:YES]];
    if (self.swtAutoCreate.isOn) { [conversionPropertyString appendFormat:@"%@\"emailNewAmbassador\" : %@,\n", [self tabSpace], [self stringForBool:self.swtEmailNewAmbassador.isOn forSwift:YES]]; }
    if (![AMBUtilities stringIsEmpty:self.tfTransactionUID.text]) { [conversionPropertyString appendFormat:@"%@\"orderId\" : \"%@\",\n", [self tabSpace], self.tfTransactionUID.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData1.text]) { [conversionPropertyString appendFormat:@"%@\"eventData1\" : \"%@\",\n", [self tabSpace], self.tfEventData1.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData2.text]) { [conversionPropertyString appendFormat:@"%@\"eventData2\" : \"%@\",\n", [self tabSpace], self.tfEventData2.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData3.text]) { [conversionPropertyString appendFormat:@"%@\"eventData3\" : \"%@\",\n", [self tabSpace], self.tfEventData3.text]; }
    [conversionPropertyString appendString:[NSString stringWithFormat:@"%@]\n\n", [self tabSpace]]];
    
    [conversionPropertyString appendString:@"        // Create options dictionary for conversion\n"];
    [conversionPropertyString appendString:@"        let optionsDictionary = [\"conversion\" : true]\n"];
    
    NSMutableString *conversionString = [[NSMutableString alloc] initWithString:@"        AmbassadorSDK.trackEvent(\"Event Name\", properties:propertiesDictionary, options:optionsDictionary) { (parameters, conversionStatus, error) in\n"];
    [conversionString appendFormat:@"%@    switch conversionStatus {\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionSuccessful:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        print(\"Success!\")\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionPending:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        print(\"Pending!\")\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    case ConversionError:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        print(\"Error!\")\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    default:\n", [self doubleTab]];
    [conversionString appendFormat:@"%@        break\n", [self doubleTab]];
    [conversionString appendFormat:@"%@    }\n", [self doubleTab]];
    [conversionString appendString:@"        }"];
    
    // Full identify/conversion string
    NSString *fullConversionString = [NSString stringWithFormat:@"%@\n%@", conversionPropertyString, conversionString];
    
    // Creates swift app delegate file
    NSString *swiftConversion = [NSString stringWithFormat:@"%@\n%@ \n", fullString, fullConversionString];
    NSString *swiftSnippet = [FileWriter swiftAppDelegateFileWithInsert:swiftConversion];
    
    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftSnippet dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

- (ZZArchiveEntry *)getJavaFile {
    NSString *spacing = @"        ";
    
    // Create IDENTIFY starting with traits
    NSMutableString *traitsString = [[NSMutableString alloc] initWithFormat:@"%@// Create bundle with traits about user\n", spacing];
    [traitsString appendFormat:@"%@Bundle traits = new Bundle();\n", spacing];
    [traitsString appendFormat:@"%@traits.putString(\"email\", \"%@\");\n", spacing, self.tfRefEmail.text];
    
    // If the optional forms are filled out, we add them to the snippet
    if (![AMBUtilities stringIsEmpty:self.tfFirstName.text]) { [traitsString appendFormat:@"%@traits.putString(\"firstName\", \"%@\");\n", spacing, self.tfFirstName.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfLastName.text]) { [traitsString appendFormat:@"%@traits.putString(\"lastName\", \"%@\");\n", spacing, self.tfLastName.text]; }
    
    NSMutableString *optionsString = nil;
    if (self.swtAutoCreate && self.selectedCampaign) {
        optionsString = [[NSMutableString alloc] initWithFormat:@"%@// Create bundle with option to auto-enroll user in campaign\n", spacing];
        [optionsString appendFormat:@"%@Bundle options = new Bundle();\n", spacing];
        [optionsString appendFormat:@"%@options.putString(\"campaign\", \"%@\");\n\n", spacing, self.selectedCampaign.campID];
    }
    
    // Creates the correct identify string based on options being nil
    NSString *userIdString = [AMBUtilities stringIsEmpty:self.tfUID.text] ? @"null" : [NSString stringWithFormat:@"\"%@\"", self.tfUID.text];
    NSString *identifyString = (optionsString) ? [NSString stringWithFormat:@"%@AmbassadorSDK.identify(%@, traits, options);\n", spacing, userIdString] :
    [NSString stringWithFormat:@"%@AmbassadorSDK.identify(%@, traits, null);\n", spacing, userIdString];
    
    // Creates a full identify string to be inserted into appDelegate template
    NSMutableString *javaIdentifyString = [[NSMutableString alloc] init];
    if (traitsString) { [javaIdentifyString appendString:traitsString]; }
    if (optionsString) { [javaIdentifyString appendString:optionsString]; }
    [javaIdentifyString appendString:identifyString];
    
    
    // Creates propertiest bundle part of string
    NSMutableString *javaString = [[NSMutableString alloc] initWithFormat:@"%@// Create properties bundle\n", [self doubleTab]];
    [javaString appendFormat:@"%@Bundle properties = new Bundle();\n", [self doubleTab]];
    [javaString appendFormat:@"%@properties.putInt(\"campaign\", %@);\n", [self doubleTab], self.selectedCampaign.campID];
    [javaString appendFormat:@"%@properties.putFloat(\"revenue\", %@f);\n", [self doubleTab], self.tfRevAmt.text];
    [javaString appendFormat:@"%@properties.putInt(\"commissionApproved\", %@);\n", [self doubleTab], [NSNumber numberWithBool:self.swtApproved.isOn]];
    if (![AMBUtilities stringIsEmpty:self.tfEventData1.text]) { [javaString appendFormat:@"%@properties.putString(\"eventData1\", %@);\n", [self doubleTab], self.tfEventData1.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData2.text]) { [javaString appendFormat:@"%@properties.putString(\"eventData2\", %@);\n", [self doubleTab], self.tfEventData2.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfEventData3.text]) { [javaString appendFormat:@"%@properties.putString(\"eventData3\", %@);\n", [self doubleTab], self.tfEventData3.text]; }
    if (![AMBUtilities stringIsEmpty:self.tfTransactionUID.text]) { [javaString appendFormat:@"%@properties.putString(\"orderId\", %@);\n", [self doubleTab], self.tfTransactionUID.text]; }
    if (self.swtAutoCreate.isOn) { [javaString appendFormat:@"%@properties.putInt(\"emailNewAmbassadord\", %@);\n\n", [self doubleTab], [NSNumber numberWithBool:self.swtEmailNewAmbassador.isOn]]; }

    [javaString appendFormat:@"%@// Create options bundle\n", [self doubleTab]];
    [javaString appendFormat:@"%@properties.putBoolean(\"conversion\", true);\n\n", [self doubleTab]];
    
    [javaString appendFormat:@"%@AmbassadorSDK.trackEvent(\"Event Name\", properties, options, new ConversionStatusListener() {\n", [self doubleTab]];
    [javaString appendFormat:@"%@    @Override\n", [self doubleTab]];
    [javaString appendFormat:@"%@    public void success() {\n", [self doubleTab]];
    [javaString appendFormat:@"%@%@println(\"Success!\");\n    %@}\n\n", [self doubleTab], [self doubleTab], [self doubleTab]];
    [javaString appendFormat:@"%@    @Override\n", [self doubleTab]];
    [javaString appendFormat:@"%@    public void pending() {\n", [self doubleTab]];
    [javaString appendFormat:@"%@%@println(\"Pending!\");\n    %@}\n\n", [self doubleTab], [self doubleTab], [self doubleTab]];
    [javaString appendFormat:@"%@    @Override\n", [self doubleTab]];
    [javaString appendFormat:@"%@    public void error() {\n", [self doubleTab]];
    [javaString appendFormat:@"%@%@println(\"Error!\");\n    %@}\n", [self doubleTab], [self doubleTab], [self doubleTab]];
    [javaString appendFormat:@"%@});\n", [self doubleTab]];

    NSString *completeSnippet = [NSString stringWithFormat:@"%@\n%@", javaIdentifyString, javaString];
    
    // Creates java file
    NSString *javaFileString = [FileWriter javaMyApplicationFileWithInsert:completeSnippet];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaFileString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (BOOL)invalidFields:(BOOL)checkReferrer {
    if (![Validator isValidEmail:self.tfReferrerEmail.text] && checkReferrer) {
        UIAlertView *blankRefAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"The Referrer Email field must be a valid email." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [blankRefAlert show];
        
        return YES;
    }
    
    if ([Validator emptyString:self.tfRefEmail.text] || [Validator emptyString:self.tfRevAmt.text] || [Validator emptyString:self.tfCampID.text]) {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"Required fields cannot be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [blankAlert show];
        
        return YES;
    }
    
    if (![Validator isValidEmail:self.tfRefEmail.text]) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:[NSString stringWithFormat:@"Please enter a valid email address."]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [invalidEmailAlert show];
        
        return YES;
    }
    
    return NO;
}

/* 
 Creates an AMBConversionParameter object based
 on the values set in the Conversion page.
 If the value is left blank, the property is set
 to the default value from the object's
 instantiation */
- (AMBConversionParameters*)conversionParameterFromValues {
    AMBConversionParameters *parameters = [[AMBConversionParameters alloc] init];
    
    // Required Params
    parameters.mbsy_email = self.tfRefEmail.text;
    parameters.mbsy_campaign = [NSNumber numberWithInteger:[self.selectedCampaign.campID integerValue]];
    parameters.mbsy_revenue = [NSNumber numberWithFloat:[self.tfRevAmt.text floatValue]];
    
    // Optional Params
    parameters.mbsy_add_to_group_id = ![self isEmpty:self.tfGroupID] && self.swtAutoCreate.isOn ? self.tfGroupID.text : parameters.mbsy_add_to_group_id;
    parameters.mbsy_first_name = ![self isEmpty:self.tfFirstName] ? self.tfFirstName.text : parameters.mbsy_first_name;
    parameters.mbsy_last_name = ![self isEmpty:self.tfLastName] ? self.tfLastName.text : parameters.mbsy_last_name;
    parameters.mbsy_email_new_ambassador = self.swtAutoCreate.isOn ? [NSNumber numberWithBool:self.swtEmailNewAmbassador.isOn] : [NSNumber numberWithBool:NO];
    parameters.mbsy_uid = ![self isEmpty:self.tfUID] ? self.tfUID.text : parameters.mbsy_uid;
    parameters.mbsy_custom1 = ![self isEmpty:self.tfCustom1] ? self.tfCustom1.text : parameters.mbsy_custom1;
    parameters.mbsy_custom2 = ![self isEmpty:self.tfCustom2] ? self.tfCustom2.text : parameters.mbsy_custom2;
    parameters.mbsy_custom3 = ![self isEmpty:self.tfCustom3] ? self.tfCustom3.text : parameters.mbsy_custom3;
    parameters.mbsy_auto_create = [NSNumber numberWithBool: self.swtAutoCreate.isOn];
    parameters.mbsy_deactivate_new_ambassador = [NSNumber numberWithBool: NO];
    parameters.mbsy_transaction_uid = ![self isEmpty:self.tfTransactionUID] ? self.tfTransactionUID.text : parameters.mbsy_transaction_uid;
    parameters.mbsy_event_data1 = ![self isEmpty:self.tfEventData1] ? self.tfEventData1.text : parameters.mbsy_event_data1;
    parameters.mbsy_event_data2 = ![self isEmpty:self.tfEventData2] ? self.tfEventData2.text : parameters.mbsy_event_data2;
    parameters.mbsy_event_data3 = ![self isEmpty:self.tfEventData3] ? self.tfEventData3.text : parameters.mbsy_event_data3;
    parameters.mbsy_is_approved = [NSNumber numberWithBool:self.swtApproved.isOn];
    
    return parameters;
}

- (BOOL)isEmpty:(UITextField*)textField {
    NSString *stringWithoutSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [stringWithoutSpaces isEqualToString:@""];
}

// Gets a string value for boolean 
- (NSString *)stringForBool:(BOOL)boolVal forSwift:(BOOL)isSwift {
    if (isSwift) {
        return boolVal ? @"true" : @"false";
    } else {
        return boolVal ? @"YES" : @"NO";
    }
}
                     
- (NSString *)shortCodeFromDictionary: (NSDictionary *)dictionary {
    // Goes through the dictionary and grabs the shortcode if there is one
    NSArray *results = dictionary[@"results"];
    NSDictionary *resultsDict = results[0];
    
    return resultsDict[@"short_code"];
}

- (void)setupSlidingViews {
    for (SlidingView *view in [self.masterView subviews]) {
        if ([view isKindOfClass:[SlidingView class]]) {
            view.datasource = self;
            [view setup];
        }
    }
    
    self.svEnroll.datasource = self;
    self.svEnroll.delegate = self;
    [self.svEnroll setup];
}

- (NSArray *)arrayFromGroupsField {
    if (![AMBUtilities stringIsEmpty:self.tfGroupID.text]) {
        NSArray *groupArray = [self.tfGroupID.text componentsSeparatedByString:@", "];
        return groupArray;
    }
    
    return nil;
}

- (void)performTrackWithShortCode:(NSString *)shortCode {
    // Saves short code based on referrer email
    [AMBValues setMbsyCookieWithCode:shortCode];
    
    // Sets all properties for converions
    NSDictionary *propertiesDictionary = @{ @"orderId" : self.tfTransactionUID.text,
                                            @"campaign" : [NSNumber numberWithInteger:[self.selectedCampaign.campID integerValue]],
                                            @"revenue" : [NSNumber numberWithFloat:[self.tfRevAmt.text floatValue]],
                                            @"commissionApproved" : [NSNumber numberWithBool:self.swtApproved.isOn],
                                            @"eventData1" : self.tfEventData1.text,
                                            @"eventData2" : self.tfEventData2.text,
                                            @"eventData3" : self.tfEventData3.text,
                                            @"emailNewAmbassador" : [NSNumber numberWithBool:self.swtEmailNewAmbassador.isOn] };
    
    // Sets option dictionary for the conversion
    NSDictionary *optionsDictionary = @{ @"conversion" : @YES,
                                         @"restrictedToInstall" : @NO };
    
    // Call the track function and trigger the conversion
    [AmbassadorSDK trackEvent:@"New event" properties:propertiesDictionary options:optionsDictionary completion:^(AMBConversionParameters *conversion, ConversionStatus conversionStatus, NSError *error) {
        switch (conversionStatus) {
            case ConversionSuccessful:
                NSLog(@"Success!");
                break;
            case ConversionPending:
                NSLog(@"Pending!");
                break;
            case ConversionError:
                NSLog(@"Error :(");
                break;
            default:
                break;
        }
    }];
}

// Called when the 'Submit' button is long-pressed for 3 seconds
- (void)testTrack:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self getShortCodeAndSubmitForTest:YES];
    }
}

- (NSString *)doubleTab {
    return @"        ";
}

- (NSString *)tabSpace {
    return @"                                 ";
}

- (NSString *)largeTabSpace {
    return @"                                     ";
}

@end
