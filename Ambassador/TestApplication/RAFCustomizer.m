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

@interface RAFCustomizer() <ColorPickerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * ivProductPhoto;
@property (nonatomic, strong) IBOutlet UITextField * tfRafName;
@property (nonatomic, strong) IBOutlet UITextField * tfCampId;
@property (nonatomic, strong) IBOutlet UIButton * btnHeaderColor;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor1;
@property (nonatomic, strong) IBOutlet UIButton * btnTextColor2;
@property (nonatomic, strong) IBOutlet UIButton * btnButtonColor;
@property (nonatomic, strong) IBOutlet UITextView * tvText1;
@property (nonatomic, strong) IBOutlet UITextView * tvText2;
@property (nonatomic, strong) IBOutlet UITableView * tblSocial;
@property (nonatomic, strong) IBOutlet UIView * masterView;

@property (nonatomic, strong) NSMutableDictionary * plistDict;
@property (nonatomic, strong) UIButton * selectedButton;

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
        NSString *rafName = self.tfRafName.text;
        RAFItem *item = [[RAFItem alloc] initWithName:rafName plistDict:self.plistDict];
        [self.delegate RAFCustomizerSavedRAF:item];
    }
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Color Picker Delegate

- (void)colorPickerColorSaved:(UIColor *)color {
    self.selectedButton.backgroundColor = color;
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
}

- (void)setValuesWithPlistDict {
    self.plistDict = (self.rafItem) ? [ThemeHandler dictionaryFromPlist:self.rafItem] : [ThemeHandler getGenericTheme];
    
    // Colors
    self.btnHeaderColor.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"NavBarColor"]];
    self.btnTextColor1.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"RAFWelcomeTextColor"]];
    self.btnTextColor2.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"RAFDescriptionTextColor"]];
    self.btnButtonColor.backgroundColor = [UIColor colorFromHexString:[self.plistDict valueForKey:@"AlertButtonBackgroundColor"]];
    
    // Text Values
    self.tvText1.text = [self.plistDict valueForKey:@"RAFWelcomeTextMessage"];
    self.tvText2.text = [self.plistDict valueForKey:@"RAFDescriptionTextMessage"];
    self.tfRafName.text = self.rafItem.rafName;
}

@end
