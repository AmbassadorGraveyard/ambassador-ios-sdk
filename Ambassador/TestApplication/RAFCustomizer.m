//
//  RAFCustomizer.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/23/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCustomizer.h"
#import "ThemeHandler.h"
#import "UIColor+AMBColorValues.h"
#import "ColorPicker.h"
#import "DefaultsHandler.h"
#import "AMBUtilities.h"
#import "CampaignObject.h"
#import "CampaignListController.h"

@interface RAFCustomizer() <ColorPickerDelegate, UITextFieldDelegate, UITextViewDelegate, CampaignListDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIImageView * ivProductPhoto;
@property (nonatomic, strong) IBOutlet UITextField * tfRafName;
@property (nonatomic, strong) IBOutlet UITextField * tfCampId;
@property (nonatomic, strong) IBOutlet UIButton * btnHeaderColor;
@property (nonatomic, strong) IBOutlet UIButton * btnHeaderTextColor;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor1;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor2;
@property (nonatomic, strong) IBOutlet UIButton * btnButtonColor;
@property (nonatomic, strong) IBOutlet UITextView * tvText1;
@property (nonatomic, strong) IBOutlet UITextView * tvText2;
@property (nonatomic, strong) IBOutlet UITableView * tblSocial;
@property (nonatomic, strong) IBOutlet UIView * masterView;

// Private properties
@property (nonatomic, strong) NSMutableDictionary * plistDict;
@property (nonatomic, strong) UIButton * selectedButton;
@property (nonatomic, strong) CampaignObject * selectedCampaignID;

@end


@implementation RAFCustomizer


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
    [self setValuesWithPlistDict];
}


#pragma mark - Button Actions

- (IBAction)colorButtonTapped:(id)sender {
    UIButton *buttonTapped = (UIButton*)sender;
    self.selectedButton = buttonTapped;
    
    ColorPicker *picker = [[ColorPicker alloc] initWithColor:[UIColor hexStringForColor:buttonTapped.backgroundColor]];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)saveTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(RAFCustomizerSavedRAF:)]) {
        [self overridePlistToSave];
        NSString *rafName = self.tfRafName.text;
        
        // If the RAFItem is nil we create a new one
        if (!self.rafItem) {
            self.rafItem = [[RAFItem alloc] initWithName:rafName plistDict:self.plistDict];
            self.rafItem.campaign = self.selectedCampaignID;
        } else {
            // If there is already a RAF Item, we override its properties instead of creating a new one
            self.rafItem.rafName = rafName;
            self.rafItem.plistDict = self.plistDict;
        }
        
        [self.delegate RAFCustomizerSavedRAF:self.rafItem];
    }
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneClicked {
    [self.masterView endEditing:YES];
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.tfCampId) {
        [self showCampaignList];
        return NO;
    }
    
    return YES;
}


#pragma mark - Color Picker Delegate

- (void)colorPickerColorSaved:(UIColor *)color {
    self.selectedButton.backgroundColor = color;
}


#pragma mark - Campaign Picker Delegate

- (void)campaignListCampaignChosen:(CampaignObject *)campaignObject {
    self.selectedCampaignID = campaignObject;
    self.tfCampId.text = campaignObject.name;
}


#pragma mark - UI Functions

- (void)setupUI {
    // Navigation Bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.23 green:0.59 blue:0.83 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    // Nav buttons
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveTapped)];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    
    // Image View
    self.ivProductPhoto.layer.cornerRadius = self.ivProductPhoto.frame.size.height/2;
    
    // Buttons
    for (UIView *button in [self.masterView subviews]) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.layer.borderWidth = 0.6;
            button.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
            button.layer.cornerRadius = button.frame.size.height/2;
        }
    }
    
    // Text Fields
    self.tfCampId.text = self.rafItem.campaign.name;
    
    // Text Views
    // Creates a toolbar with a 'Done' button in it for dismissing textviews
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneClicked)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    for (UITextView *textView  in [self.masterView subviews]) {
        if ([textView isKindOfClass:[UITextView class]]) {
            textView.layer.borderWidth = 0.5;
            textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            textView.layer.cornerRadius = 4;
            textView.inputAccessoryView = keyboardDoneButtonView;
        }
    }
}

- (void)setValuesWithPlistDict {
    self.plistDict = (self.rafItem) ? [ThemeHandler dictionaryFromPlist:self.rafItem] : [ThemeHandler getGenericTheme];
    
    // Colors
    self.btnHeaderColor.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"NavBarColor"]];
    self.btnHeaderTextColor.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"NavBarTextColor"]];
    self.btnTextColor1.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"RAFWelcomeTextColor"]];
    self.btnTextColor2.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"RAFDescriptionTextColor"]];
    self.btnButtonColor.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"AlertButtonBackgroundColor"]];
    
    // Text Values
    self.tvText1.text = [self.plistDict valueForKey:@"RAFWelcomeTextMessage"];
    self.tvText2.text = [self.plistDict valueForKey:@"RAFDescriptionTextMessage"];
    self.tfRafName.text = self.rafItem.rafName;
}


#pragma mark - Helper Functions

- (void)overridePlistToSave {
    // Grabs all the color values for buttons and assigns them hex string values
    NSString *headerColorString = [UIColor hexStringForColor:self.btnHeaderColor.backgroundColor];
    NSString *headerTextColorString = [UIColor hexStringForColor:self.btnHeaderTextColor.backgroundColor];
    NSString *textColorString1 = [UIColor hexStringForColor:self.btnTextColor1.backgroundColor];
    NSString *textColorString2 = [UIColor hexStringForColor:self.btnTextColor2.backgroundColor];
    NSString *buttonColorString = [UIColor hexStringForColor:self.btnButtonColor.backgroundColor];
    
    // Overrides color in the plist
    [self.plistDict setValue:headerColorString forKey:@"NavBarColor"];
    [self.plistDict setValue:headerTextColorString forKey:@"NavBarTextColor"];
    [self.plistDict setValue:textColorString1 forKey:@"RAFWelcomeTextColor"];
    [self.plistDict setValue:textColorString2 forKey:@"RAFDescriptionTextColor"];
    [self.plistDict setValue:buttonColorString forKey:@"ContactSendButtonBackgroundColor"];
    [self.plistDict setValue:buttonColorString forKey:@"AlertButtonBackgroundColor"];
    [self.plistDict setValue:buttonColorString forKey:@"ContactAvatarBackgroundColor"];
    [self.plistDict setValue:buttonColorString forKey:@"ContactTableCheckMarkColor"];
    
    // Overrides strings in plist
    [self.plistDict setValue:self.tvText1.text forKey:@"RAFWelcomeTextMessage"];
    [self.plistDict setValue:self.tvText2.text forKey:@"RAFDescriptionTextMessage"];
}

- (void)getCampaignList {
    // Sets up request
    NSURL *ambassadorURL;
    #if AMBPRODUCTION
        ambassadorURL = [NSURL URLWithString:@"https://api.getambassador.com/campaigns/"];
    #else
        ambassadorURL = [NSURL URLWithString:@"https://dev-ambassador-api.herokuapp.com/campaigns/"];
    #endif
    
    // Creates Authorization string
    NSString *authString = [NSString stringWithFormat:@"UniversalToken %@", [DefaultsHandler getUniversalToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ambassadorURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    
    // Makes network call
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [AMBUtilities isSuccessfulStatusCode:statusCode]) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", results);
            
            // Save the campaign list to defaults and then show list
            [self saveCampaings:results];
            [self showCampaignList];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to load campaigns" message:@"Unable to load campaigns at this time. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }] resume];
}

- (void)saveCampaings:(NSDictionary*)results {
    // Get list of campaigns
    NSArray *campaignArray = results[@"results"];
    
    NSMutableArray *arrayToSave = [[NSMutableArray alloc] init];
    
    // Goes through each campaign and creates a campaingObject from that which will be stored to defaults
    for (int i = 0; i < campaignArray.count; i++) {
        NSDictionary *campaign = campaignArray[i];
        CampaignObject *object = [[CampaignObject alloc] init];
        object.name = campaign[@"name"];
        object.campID = [NSString stringWithFormat:@"%@", campaign[@"uid"]];
        
        [arrayToSave addObject:object];
    }
    
    [DefaultsHandler saveCampaignList:[NSArray arrayWithArray:arrayToSave]];
}

- (void)showCampaignList {
    NSArray *campaigns = [DefaultsHandler getCampaignList];
    
    if (campaigns.count > 0) {
        CampaignListController *listController = [[CampaignListController alloc] initWithCampaigns:campaigns];
        listController.delegate = self;
        [self presentViewController:listController animated:YES completion:nil];
    } else {
        [self getCampaignList];
    }
}

@end
