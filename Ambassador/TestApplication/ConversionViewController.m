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

@interface ConversionViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView * imgBGView;
@property (nonatomic, strong) IBOutlet UIButton * btnSubmit;
@property (nonatomic, strong) IBOutlet UITextField * tfRefEmail;
@property (nonatomic, strong) IBOutlet UITextField * tfRevAmt;
@property (nonatomic, strong) IBOutlet UITextField * tfCampID;
@property (nonatomic, strong) IBOutlet UISwitch * swtApproved;
@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;

@property (nonatomic, strong) UITextField * selectedTextField;

@end

@implementation ConversionViewController

CGFloat currentOffset;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTheme];
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
    [self performConversionAction];
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

- (void)registerConversion {
    // Creates a formatter to get an NSNumber from a String
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber *campIDNumber = [formatter numberFromString:self.tfCampID.text];
    NSNumber *revAmt = [formatter numberFromString:self.tfRevAmt.text];
    BOOL shouldAutoApprove = [self.swtApproved isOn];
    
    AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];
    conversionParameters.mbsy_email = self.tfRefEmail.text;
    conversionParameters.mbsy_campaign = campIDNumber;
    conversionParameters.mbsy_revenue = revAmt;
    conversionParameters.mbsy_is_approved = [NSNumber numberWithBool:shouldAutoApprove];
    
    [AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error registering conversion - %@", error);
        } else {
            NSLog(@"Conversion registered successfully!");
        }
    }];
}

- (void)performConversionAction {
    if (![self invalidFields]) {
        [self registerConversion];
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Great!" message:@"You have successfully registered a conversion." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [successAlert show];
    }
}

- (void)exportConversionCode {
    if (![self invalidFields]) {
        NSString *titleString = [NSString stringWithFormat:@"Ambassador Conversion Code Snippet v%@", [ValuesHandler getVersionNumber]];
        NSString *fullCodeSnippet = [NSString stringWithFormat:@"Objective-C\n\n%@\n\n\nSwift\n\n%@", [self getObjcSnippet], [self getSwiftSnippet]];
        
        NSString *shareString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@", titleString, fullCodeSnippet]];
        
        // Package up snippet to share
        NSArray * shareItems = @[shareString];
        UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
        [avc setValue:@"Ambassador Conversion Code Snippet" forKey:@"subject"];
        [self presentViewController:avc animated:YES completion:nil];
    }
}

- (NSString*)getObjcSnippet {
    // Creates string from boolean
    NSString *boolString = [self.swtApproved isOn] ? @"YES" : @"NO";
    
    // Create a code snippet based on the info entered into the fields for the conversion
    NSString *snippetLine1 = @"AMBConversionParameters *conversionParameters = [[AMBConversionParameters alloc] init];";
    NSString *snippetLine2 = [NSString stringWithFormat:@"conversionParameters.mbsy_email = @\"%@\";", self.tfRefEmail.text];
    NSString *snippetLine3 = [NSString stringWithFormat:@"conversionParameters.mbsy_campaign = @%@;", self.tfCampID.text];
    NSString *snippetLine4 = [NSString stringWithFormat:@"conversionParameters.mbsy_revenue = @%@;", self.tfRevAmt.text];
    NSString *snippetLine5 = [NSString stringWithFormat:@"conversionParameters.mbsy_is_approved = @%@;", boolString];
    
    NSString *registerLine = @"[AmbassadorSDK registerConversion:conversionParameters restrictToInstall:NO completion:^(NSError *error) {";
    NSString *registerLine2 = @"    if (error) {";
    NSString *registerLine3 = @"        NSLog(@\"Error registering conversion - %@\", error);";
    NSString *registerLine4 = @"    } else {";
    NSString *registerLine5 = @"        NSLog(@\"Conversion registered successfully!\");";
    NSString *registerLine6 = @"    }";
    NSString *registerLine7 = @"}];";
    
    // Creates first part of snippet for setting params
    NSArray *stringArray1 = @[snippetLine1, snippetLine2, snippetLine3, snippetLine4, snippetLine5];
    NSMutableString *conversionParamString = [[NSMutableString alloc] init];
    
    for (NSString *string in stringArray1) {
        [conversionParamString appendString:[NSString stringWithFormat:@"%@\n", string]];
    }
    
    // Creates second part of snippet for registering conversion
    NSArray *stringArray2 = @[registerLine, registerLine2, registerLine3, registerLine4, registerLine5, registerLine6, registerLine7];
    NSMutableString *implementationString = [[NSMutableString alloc] init];
    
    for (NSString *string in stringArray2) {
        [implementationString appendString:[NSString stringWithFormat:@"%@\n", string]];
    }
    
    NSString *objcSnippet = [NSString stringWithFormat:@"%@\n%@", conversionParamString, implementationString];
    
    return objcSnippet;
}

- (NSString*)getSwiftSnippet {
    // Creates string from boolean
    NSString *boolString = [self.swtApproved isOn] ? @"true" : @"false";
    
    // Create a code snippet based on the info entered into the fields for the conversion
    NSString *snippetLine1 = @"let conversionParameters = AMBConversionParameters()";
    NSString *snippetLine2 = [NSString stringWithFormat:@"conversionParameters.mbsy_email = \"%@\";", self.tfRefEmail.text];
    NSString *snippetLine3 = [NSString stringWithFormat:@"conversionParameters.mbsy_campaign = %@;", self.tfCampID.text];
    NSString *snippetLine4 = [NSString stringWithFormat:@"conversionParameters.mbsy_revenue = %@;", self.tfRevAmt.text];
    NSString *snippetLine5 = [NSString stringWithFormat:@"conversionParameters.mbsy_is_approved = %@", boolString];
    
    NSString *registerLine = @"AmbassadorSDK.registerConversion(conversionParameters, restrictToInstall: false) { (error) -> Void in";
    NSString *registerLine2 = @"    if ((error) != nil) {";
    NSString *registerLine3 = @"        print(\"Error \(error)\")";
    NSString *registerLine4 = @"    } else {";
    NSString *registerLine5 = @"        print(\"All conversion parameters are set properly\")";
    NSString *registerLine6 = @"    }";
    NSString *registerLine7 = @"}";

    // Creates first part of snippet for setting params
    NSArray *stringArray1 = @[snippetLine1, snippetLine2, snippetLine3, snippetLine4, snippetLine5];
    NSMutableString *conversionParamString = [[NSMutableString alloc] init];
    
    for (NSString *string in stringArray1) {
        [conversionParamString appendString:[NSString stringWithFormat:@"%@\n", string]];
    }
    
    // Creates second part of snippet for registering conversion
    NSArray *stringArray2 = @[registerLine, registerLine2, registerLine3, registerLine4, registerLine5, registerLine6, registerLine7];
    NSMutableString *implementationString = [[NSMutableString alloc] init];
    
    for (NSString *string in stringArray2) {
        [implementationString appendString:[NSString stringWithFormat:@"%@\n", string]];
    }
    
    NSString *swiftSnippet = [NSString stringWithFormat:@"%@\n%@", conversionParamString, implementationString];
    
    return swiftSnippet;
}

- (BOOL)invalidFields {
    if ([Validator emptyString:self.tfRefEmail.text] || [Validator emptyString:self.tfRevAmt.text] || [Validator emptyString:self.tfCampID.text]) {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"No fields can be left blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
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

@end
