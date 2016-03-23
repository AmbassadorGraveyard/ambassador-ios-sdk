//
//  RAFCustomizer.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/23/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCustomizer.h"

@interface RAFCustomizer()

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


@end


@implementation RAFCustomizer


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
}


#pragma mark - Button Actions

- (void)saveTapped {
    
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.btnHeaderColor.layer.cornerRadius = self.btnHeaderColor.frame.size.height/2;
    self.btnTextColor1.layer.cornerRadius = self.btnTextColor1.frame.size.height/2;
    self.btnTextColor2.layer.cornerRadius = self.btnTextColor2.frame.size.height/2;
    self.btnButtonColor.layer.cornerRadius = self.btnButtonColor.frame.size.height/2;
}

@end
