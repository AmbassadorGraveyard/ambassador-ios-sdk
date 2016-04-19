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
#import "SocialShareOptionsHandler.h"
#import "LoadingScreen.h"
#import "Validator.h"

@interface RAFCustomizer() <ColorPickerDelegate, UITextFieldDelegate, UITextViewDelegate, CampaignListDelegate,
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate, SocialShareHandlerDelegate, UIAlertViewDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIImageView * ivProductPhoto;
@property (nonatomic, strong) IBOutlet UIImageView * plusImage;
@property (nonatomic, strong) IBOutlet UITextField * tfRafName;
@property (nonatomic, strong) IBOutlet UITextField * tfCampId;
@property (nonatomic, strong) IBOutlet UIButton * btnHeaderColor;
@property (nonatomic, strong) IBOutlet UIButton * btnHeaderTextColor;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor1;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor2;
@property (nonatomic, strong) IBOutlet UIButton * btnButtonColor;
@property (nonatomic, strong) IBOutlet UIButton * btnClearImage;
@property (nonatomic, strong) IBOutlet UITextView * tvText1;
@property (nonatomic, strong) IBOutlet UITextView * tvText2;
@property (nonatomic, strong) IBOutlet UITableView * tblSocial;
@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * socialTableHeight;
@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) IBOutlet UITextView * tvHeaderText;

// Private properties
@property (nonatomic, strong) NSMutableDictionary * plistDict;
@property (nonatomic, strong) UIButton * selectedButton;
@property (nonatomic, strong) CampaignObject * selectedCampaignID;
@property (nonatomic, strong) UIImage * selectedImage;
@property (nonatomic, strong) NSMutableArray * socialArray;
@property (nonatomic, strong) SocialShareOptionsHandler * socialHandler;
@property (nonatomic, strong) UIView * selectedView;

@end


@implementation RAFCustomizer

NSInteger currentScrollPoint;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setValuesWithPlistDict];
    [self setupUI];
    
    // Image View tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImagePicker)];
    [self.ivProductPhoto addGestureRecognizer:tap];
    
    // Listens for when keyboard shows/hides
    [self registerForKeyboardNotificaitons];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Stops listening for keyboard show and hide
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [LoadingScreen rotateLoadingScreenForView:self.parentViewController.view];
}


#pragma mark - Button Actions

- (IBAction)colorButtonTapped:(id)sender {
    UIButton *buttonTapped = (UIButton*)sender;
    self.selectedButton = buttonTapped;
    
    ColorPicker *picker = [[ColorPicker alloc] initWithColor:[UIColor hexStringForColor:buttonTapped.backgroundColor]];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)clearImage:(id)sender {
    // Update the viewController for cleared image
    self.selectedImage = nil;
    [self setupUI];
}

- (void)saveTapped {
    if (![self validForm]) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(RAFCustomizerSavedRAF:)]) {
        // Override the existing plist theme with new RAF Customizer values
        [self overridePlistToSave];
        NSString *rafName = self.tfRafName.text;
        
        // If the RAFItem is nil we create a new one
        if (!self.rafItem) {
            self.rafItem = [[RAFItem alloc] initWithName:rafName plistDict:self.plistDict];
        } else {
            // If there is already a RAF Item, we override its properties instead of creating a new one
            self.rafItem.rafName = rafName;
        }
        
        // Override properties of the RAF Item
        [self overridePlistIfImage:self.rafItem.plistFullName];
        self.rafItem.campaign = self.selectedCampaignID;
        [self.rafItem generateXMLFromPlist:self.plistDict];
        
        [self.delegate RAFCustomizerSavedRAF:self.rafItem];
    }
}

- (void)cancelTapped {
    [self showCancelConfirmation];
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
        [self.tfRafName resignFirstResponder];
        
        // Show campaign list
        CampaignListController *campController = [[CampaignListController alloc] init];
        campController.delegate = self;
        [self presentViewController:campController animated:YES completion:nil];
        
        return NO;
    } else {
        self.selectedView = textField;
    }
    
    return YES;
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.selectedView = textView;
    return YES;
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Checks to make sure user wants to cancel 
    if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - ImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.ivProductPhoto.image = info[@"UIImagePickerControllerOriginalImage"];
    self.selectedImage = self.ivProductPhoto.image;
    self.btnClearImage.enabled = YES;
    self.plusImage.hidden = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard Listener

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    // Saves where the scrollview was currently at before scrolling
    currentScrollPoint = self.scrollView.contentOffset.y;
    
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.selectedView.frame.origin.y + self.selectedView.frame.size.height + 10;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    
    if (keyboardFrame.size.height > difference) {
        CGFloat newY = keyboardFrame.size.height - difference;
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Resets the scrollview to original position
    [self.scrollView setContentOffset:CGPointMake(0, currentScrollPoint) animated:YES];
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


#pragma mark - Social Share Handler Delegate

/*
 Delegate function that gets fired whenever
 the social channel order is rearranged. 
 */
- (void)socialShareHandlerUpdated:(NSMutableArray *)socialArray {
    self.socialArray = socialArray;
}

/* 
 Delegate function that gets fired whenever
 a social channel is enabled or disabled.
 */
- (void)socialShareHandlerEnabledObjectsUpdated:(NSMutableArray *)enabledArray {
    self.socialArray = enabledArray;
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
    self.ivProductPhoto.userInteractionEnabled = YES;
    self.ivProductPhoto.image = self.selectedImage;
    self.plusImage.hidden = (self.selectedImage) ? YES : NO;
    self.btnClearImage.enabled = (self.selectedImage) ? YES : NO;
    
    // Buttons
    for (UIView *button in [self.masterView subviews]) {
        if ([button isKindOfClass:[UIButton class]] && button != self.btnClearImage) {
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
    // Checks if a new whether to setup from existing theme or Generic theme
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
    self.tvHeaderText.text = [self.plistDict valueForKey:@"NavBarTextMessage"];
    self.tfRafName.text = self.rafItem.rafName;
    
    // RAF Item Values
    if (self.rafItem) {
        self.selectedCampaignID = self.rafItem.campaign;
        self.selectedImage = [ThemeHandler getImageForRAF:self.rafItem];
    }
    
    // Social Table
    [self getSocialObjectsFromPlist];
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
    NSString *headerText = ![Validator emptyString:self.tvHeaderText.text] ? self.tvHeaderText.text : @" ";
    NSString *textValue1 = ![Validator emptyString:self.tvText1.text] ? self.tvText1.text : @" ";
    NSString *textValue2 = ![Validator emptyString:self.tvText2.text] ? self.tvText2.text : @" ";
    
    [self.plistDict setValue:headerText forKey:@"NavBarTextMessage"];
    [self.plistDict setValue:textValue1 forKey:@"RAFWelcomeTextMessage"];
    [self.plistDict setValue:textValue2 forKey:@"RAFDescriptionTextMessage"];
    
    // Overrides social table
    [self.plistDict setValue:[self stringFromSocialChannels] forKey:@"Channels"];
}

- (void)overridePlistIfImage:(NSString *)rafPlist {
    // Checks if the user selected an image an adds it to the plist if so
    if (self.selectedImage) {
        NSString *imageString = [rafPlist stringByAppendingString:@"Image"];
        NSString *imagePlistValue = [imageString stringByAppendingString:@", 1"];
        [self.plistDict setValue:imagePlistValue forKey:@"RAFLogo"];
        [ThemeHandler saveImage:self.selectedImage forTheme:self.rafItem];
        self.rafItem.imageFilePath = imageString;
    } else {
        // If there is an image tied to the RAF, we remove it from local storage
        [ThemeHandler removeImageForTheme:self.rafItem];
        self.rafItem.imageFilePath = nil;
        [self.plistDict setValue:@"" forKey:@"RAFLogo"];
    }
    
    self.rafItem.plistDict = self.plistDict;
}

- (void)openImagePicker {
    // Opens image picker for photos saved to album on device
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)getSocialObjectsFromPlist {
    // Gets string for social channel order from plist
    NSString *channelString = self.plistDict[@"Channels"];
    
    // Creates an array based on enabled social channels
    NSMutableArray *onArray = [[NSMutableArray alloc] initWithArray:[channelString componentsSeparatedByString:@","]];
    
    // Goes through each all channel strings from plist and removes spaces
    for (int i = 0; i < onArray.count; i++) {
        NSString *socialString = onArray[i];
        socialString = [socialString stringByReplacingOccurrencesOfString:@" " withString:@""];
        [onArray replaceObjectAtIndex:i withObject:socialString];
    }
    
    self.socialArray = [NSMutableArray arrayWithArray:onArray];
    
    // Array of all channels which will not change unless we add new channels to the SDK
    NSMutableArray *allChannelArray = [NSMutableArray arrayWithObjects:@"Facebook", @"Twitter", @"LinkedIn", @"SMS", @"Email", nil];
    
    /* 
     Goes through the enabled channel array and adds
     any channels that may be disabled, to the end of
     the channel list for re-enabling/rearranging 
     */
    for (int i = 0; i < allChannelArray.count; i++) {
        NSString *socialChannel = allChannelArray[i];
        
        if (![self.socialArray containsObject:socialChannel]) {
            [self.socialArray addObject:socialChannel];
        }
    }
    
    [self setupSocialTableView:onArray];
}

- (void)setupSocialTableView:(NSMutableArray*)enabledChannels {
    // Init our Social Handler class which is the datasource and delegate for the social tableview
    if (!self.socialHandler) {
        // Creates new array to pass since, self.socialArray will be getting altered
        NSMutableArray *fullArray = [NSMutableArray arrayWithArray:self.socialArray];
        
        self.socialHandler = [[SocialShareOptionsHandler alloc] initWithArrayOrder:fullArray onArray:enabledChannels];
        self.socialHandler.delegate = self;
        
        // Resets array to only contain enabled channels
        [self.socialArray removeAllObjects];
        [self.socialArray addObjectsFromArray:enabledChannels];
    }
    
    // Set values for social tableview
    self.tblSocial.delegate = self.socialHandler;
    self.tblSocial.dataSource = self.socialHandler;
    self.tblSocial.editing = YES;
    self.socialTableHeight.constant = 5 * 71 - 1;
}

/*
 Goes through all channels in the social array
 and creates a string  for the Channles value 
 in the theme plist.
 Ex: 'Facebook, Twitter, LinkedIn, SMS, Email'
 */
- (NSString *)stringFromSocialChannels {
    NSMutableString *channelString = [[NSMutableString alloc] init];
    
    for (NSString *socialString in self.socialArray) {
        NSString *appendString = (socialString != [self.socialArray lastObject]) ? [NSString stringWithFormat:@"%@,", socialString] : socialString;
        [channelString appendString:appendString];
    }
    
    return channelString;
}

- (BOOL)validForm {
    // Checks for empty RAF Name
    if ([AMBUtilities stringIsEmpty:self.tfRafName.text]) {
        UIAlertView *emptyNameAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"The Integration Name field cannot be blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [emptyNameAlert show];
        return NO;
    }
    
    // Checks for Empty campaign ID
    if ([AMBUtilities stringIsEmpty:self.tfCampId.text]) {
        UIAlertView *emptyIDAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"The Campaign field cannot be blank." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [emptyIDAlert show];
        return NO;
    }
    
    // Checks for Duplicate RAF Name if new RAF
    NSString *nameWithoutSpaces = [self.tfRafName.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([ThemeHandler duplicateRAFName:nameWithoutSpaces] && !self.rafItem) {
        NSString *errorString = [NSString stringWithFormat:@"Duplicate RAF names are not allowed: %@", self.tfRafName.text];
        UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:errorString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [duplicateAlert show];
        return NO;
    }
    
    return YES;
}

- (void)showCancelConfirmation {
    UIAlertView *cancelAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"By cancelling, all changes will be lost." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [cancelAlert show];
}

@end
