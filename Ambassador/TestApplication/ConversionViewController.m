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
#import <MessageUI/MessageUI.h>
#import <ZipZap/ZipZap.h>
#import "SlidingView.h"

@interface ConversionViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate, SlidingViewDatasource>

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

// Private properties
@property (nonatomic, strong) UITextField * selectedTextField;

@end


@implementation ConversionViewController

CGFloat currentOffset;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
    [self setupSlidingViews];
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
    self.selectedTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"Message sent successfully!");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Message failed to send");
            break;
        default:
            NSLog(@"Message was not sent");
            break;
    }
}


#pragma mark - Keyboard Listeners

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    // Saves where the scrollview was currently at before scrolling
    currentOffset = self.scrollView.contentOffset.y;
    
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.selectedTextField.frame.origin.y + 10;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    
    if (keyboardFrame.size.height > difference) {
        CGFloat newY = keyboardFrame.size.height - difference;
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Resets the scrollview to original position
    [self.scrollView setContentOffset:CGPointMake(0, currentOffset) animated:YES];
}


#pragma mark - Sliding View Datasource

- (NSInteger)slidingViewExpandedHeight:(SlidingView *)slidingView {
    if (slidingView == self.svAmbassador) {
        return 83;
    } else if (slidingView == self.svCustomer) {
        return 538;
    } else {
        return 388;
    }
}

- (NSInteger)slidingViewCollapsedHeight:(SlidingView *)slidingView {
    return 35;
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
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.tfCampID.inputAccessoryView = keyboardDoneButtonView;
    self.tfRevAmt.inputAccessoryView = keyboardDoneButtonView;
}

- (void)addConversionExportButton {
    UIBarButtonItem *btnExport = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exportIconSm"] style:UIBarButtonItemStylePlain target:self action:@selector(exportConversionCode)];
    self.tabBarController.navigationItem.rightBarButtonItem = btnExport;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Helper Functions

- (void)getShortCodeAndSubmit {
    // Sets up request
    NSString *urlString = [NSString stringWithFormat:@"urls/?campaign_uid=%@&email=%@", self.tfCampID.text, self.tfReferrerEmail.text];
    
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
            NSLog(@"%@", returnDict);
            
            // Checks if the count is greater than zero
            if (returnDict[@"count"] > [NSNumber numberWithInteger:0]) {
                // Grabs the shortcode from the response and makes a conversion call
                NSString *shortCode = [self shortCodeFromDictionary:returnDict];
                [self registerConversionWithShortCode:shortCode];
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
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error registering conversion - %@", error);
        } else {
            NSLog(@"Conversion registered successfully!");
        }
    }];
}

- (void)performConversionActionWithShortCode {
    if (![self invalidFields]) {
        [self getShortCodeAndSubmit];
    }
}

- (void)exportConversionCode {
    if (![self invalidFields]) {
        // Creates a new directiry in the documents folder
        NSString *filePath = [[FileWriter documentsPath] stringByAppendingPathComponent:@"ambassador-conversion"];
        
        // Creates a new zip file containing all different files
        ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
        [newArchive updateEntries:@[[self getObjcFile], [self getSwiftFile], [self getJavaFile]] error:nil];
        
        // Create an email with attachments
        MFMailComposeViewController *mailVc = [[MFMailComposeViewController alloc] init];
        mailVc.mailComposeDelegate = self;
        [mailVc addAttachmentData:[NSData dataWithContentsOfFile:filePath] mimeType:@"application/zip" fileName:@"ambassador-conversion.zip"];
        [mailVc setSubject:@"Ambassador Conversion Code"];
        [self presentViewController:mailVc animated:YES completion:nil];
    }
}

- (ZZArchiveEntry *)getObjcFile {
    // Creates first part of snippet for setting params
    NSMutableString *conversionParamString = [NSMutableString stringWithString:@"\n    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];\n\n    // Set required properties\n"];
    
    // Creates an AMBConversionParameter object
    AMBConversionParameters *params = [self conversionParameterFromValues];
    NSDictionary *dict = [params propertyDictionary];
    
    // Goes through each property in the conversionparam object
    for (NSString *string in [params propertyArray]) {
        // Creates the base setter string
        NSString *setterString = [AMBConversionParameters isStringProperty:string] ? @"    conversionParameters.%@ = @\"%@\"; \n" : @"    conversionParameters.%@ = @%@; \n";
        NSString *boolString = nil;
        
        // Checks if property is a boolean and creates a string based on the boolean value
        if ([AMBConversionParameters isBoolProperty:string]) {
            BOOL boolValue = [[dict valueForKey:string] boolValue];
            boolString = [self stringForBool:boolValue forSwift:NO];
        }
        
        // Creates full propertyString and appends to to the full string
        NSString *propString = boolString ? [NSString stringWithFormat:setterString, string, boolString] : [NSString stringWithFormat:setterString, string, [dict valueForKey:string]];
        [conversionParamString appendString: propString];
        
        // If the property is 'revenue' then we add a new comment line to start optional properties
        if ([string isEqualToString:@"mbsy_revenue"]) { [conversionParamString appendString:@"\n    // Set optional properties\n"];}
    }
    
    // Builds implementation string
    NSMutableString *implementationString = [[NSMutableString alloc] initWithString:@"    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) { \n"];
    [implementationString appendString:@"        if (error) { \n"];
    [implementationString appendString:@"            NSLog(@\"Error registering conversion - %@\", error); \n"];
    [implementationString appendString:@"        } else { \n"];
    [implementationString appendString:@"            NSLog(@\"Conversion registered successfully!\"); \n"];
    [implementationString appendString:@"        } \n"];
    [implementationString appendString:@"    }];"];
    
    // Creats app delegate file
    NSString *objcConversion = [NSString stringWithFormat:@"%@\n%@ \n\n", conversionParamString, implementationString];
    NSString *objcSnippet = [FileWriter objcAppDelegateFileWithInsert:objcConversion];
    
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objcSnippet dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

- (ZZArchiveEntry *)getSwiftFile {
    // Creates first part of snippet for setting params
    NSMutableString *conversionParamString = [NSMutableString stringWithString:@"\n        let conversionParameters = AMBConversionParameters()\n\n        // Set required properties\n"];
    
    // Creates an AMBConversionParameter object
    AMBConversionParameters *params = [self conversionParameterFromValues];
    NSDictionary *dict = [params propertyDictionary];
    
    // Goes through each property in the conversionparam object
    for (NSString *string in [params propertyArray]) {
        // Creates the base setter string
        NSString *setterString = [AMBConversionParameters isStringProperty:string] ? @"        conversionParameters.%@ = \"%@\" \n" : @"        conversionParameters.%@ = %@ \n";
        
        NSString *boolString = nil;
        
        // Checks if property is a boolean and creates a string based on the boolean value
        if ([AMBConversionParameters isBoolProperty:string]) {
            BOOL boolValue = [[dict valueForKey:string] boolValue];
            boolString = [self stringForBool:boolValue forSwift:YES];
        }
        
        // Creates full propertyString and appends to to the full string
        NSString *propString = boolString ? [NSString stringWithFormat:setterString, string, boolString] : [NSString stringWithFormat:setterString, string, [dict valueForKey:string]];
        [conversionParamString appendString: propString];
        
        // If the property is 'revenue' then we add a new comment line to start optional properties
        if ([string isEqualToString:@"mbsy_revenue"]) { [conversionParamString appendString:@"\n        // Set optional properties\n"];}
    }

    NSMutableString *implementationString = [[NSMutableString alloc] initWithString:@"        AmbassadorSDK.registerConversion(conversionParameters, restrictToInstall: false) { (error) -> Void in \n"];
    [implementationString appendString:@"            if ((error) != nil) { \n"];
    [implementationString appendString:@"                print(\"Error \\(error)\") \n"];
    [implementationString appendString:@"            } else { \n"];
    [implementationString appendString:@"                print(\"All conversion parameters are set properly\") \n"];
    [implementationString appendString:@"            } \n"];
    [implementationString appendString:@"        }"];
    
    // Creates swift app delegate file
    NSString *swiftConversion = [NSString stringWithFormat:@"%@\n%@ \n\n", conversionParamString, implementationString];
    NSString *swiftSnippet = [FileWriter swiftAppDelegateFileWithInsert:swiftConversion];
    
    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"AppDelegate.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftSnippet dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

- (ZZArchiveEntry *)getJavaFile {
    // Creats conversion parameter object from values
    AMBConversionParameters *params = [self conversionParameterFromValues];
    
    // Build java conversion string
    NSMutableString *conversionString = [[NSMutableString alloc] initWithString:@"        ConversionParameters conversionParameters = new ConversionParameters.Builder()\n"];
    [conversionString appendString:[NSString stringWithFormat:@"            .setEmail(\"%@\")\n", params.mbsy_email]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setRevenue(%@f)\n", params.mbsy_revenue]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setCampaign(%@)\n", params.mbsy_campaign]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setAddToGroupId(\"%@\")\n", params.mbsy_add_to_group_id]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setFirstName(\"%@\")\n", params.mbsy_first_name]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setLastName(\"%@\")\n", params.mbsy_last_name]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setUID(\"%@\")\n", params.mbsy_uid]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setCustom1(\"%@\")\n", params.mbsy_custom1]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setCustom2(\"%@\")\n", params.mbsy_custom2]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setCustom3(\"%@\")\n", params.mbsy_custom3]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setTransactionUID(\"%@\")\n", params.mbsy_transaction_uid]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setEventData1(\"%@\")\n", params.mbsy_event_data1]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setEventData2(\"%@\")\n", params.mbsy_event_data2]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setEventData3(\"%@\")\n", params.mbsy_event_data3]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setIsApproved(%@)\n", params.mbsy_is_approved]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setAutoCreate(%@)\n", params.mbsy_auto_create]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setDeactivateNewAmbassador(%@)\n", params.mbsy_deactivate_new_ambassador]];
    [conversionString appendString:[NSString stringWithFormat:@"            .setEmailNewAmbassador(%@)\n", params.mbsy_email_new_ambassador]];
    [conversionString appendString:@"            .build();\n"];
    [conversionString appendString:@"        AmbassadorSDK.registerConversion(conversionParameters, false);\n"];
    
    // Creates java file
    NSString *javaFileString = [FileWriter javaMyApplicationFileWithInsert:conversionString];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaFileString dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

- (NSData *)getReadme {
    NSString *readmeString = [FileWriter readMeForRequest:@"conversion"];
    return [readmeString dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)invalidFields {
    if (![Validator isValidEmail:self.tfReferrerEmail.text]) {
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
    parameters.mbsy_campaign = [NSNumber numberWithInteger:[self.tfCampID.text integerValue]];
    parameters.mbsy_revenue = [NSNumber numberWithFloat:[self.tfRevAmt.text floatValue]];
    
    // Optional Params
    parameters.mbsy_add_to_group_id = ![self isEmpty:self.tfGroupID] ? self.tfGroupID.text : parameters.mbsy_add_to_group_id;
    parameters.mbsy_first_name = ![self isEmpty:self.tfFirstName] ? self.tfFirstName.text : parameters.mbsy_first_name;
    parameters.mbsy_last_name = ![self isEmpty:self.tfLastName] ? self.tfLastName.text : parameters.mbsy_last_name;
    parameters.mbsy_email_new_ambassador = [NSNumber numberWithBool:self.swtEmailNewAmbassador.isOn];
    parameters.mbsy_uid = ![self isEmpty:self.tfUID] ? self.tfUID.text : parameters.mbsy_uid;
    parameters.mbsy_custom1 = ![self isEmpty:self.tfCustom1] ? self.tfCustom1.text : parameters.mbsy_custom1;
    parameters.mbsy_custom2 = ![self isEmpty:self.tfCustom2] ? self.tfCustom2.text : parameters.mbsy_custom2;
    parameters.mbsy_custom3 = ![self isEmpty:self.tfCustom3] ? self.tfCustom3.text : parameters.mbsy_custom3;
    parameters.mbsy_auto_create = [NSNumber numberWithBool: self.swtAutoCreate.isOn];
    parameters.mbsy_deactivate_new_ambassador = [NSNumber numberWithBool: self.swtDeactivateNewAmbassador.isOn];
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
}

@end
