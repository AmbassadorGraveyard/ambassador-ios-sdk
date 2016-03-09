//
//  AMBWelcomeScreenViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenViewController.h"
#import "AMBLinkCell.h"

@interface AMBWelcomeScreenViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AMBLinkCellDelegate>

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivProfilePic;
@property (nonatomic, strong) IBOutlet UILabel * lblReferred;
@property (nonatomic, strong) IBOutlet UILabel * lblDescription;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;
@property (nonatomic, strong) IBOutlet UICollectionView * linkCollectionView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * collectionViewHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * buttonHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * referralTextBottom;

@property (nonatomic, strong) NSArray * linkArray;
@property (nonatomic, strong) UIColor * welcomeScreenAccent;
@property (nonatomic, strong) NSString * referrerName;

@end


@implementation AMBWelcomeScreenViewController

NSInteger const CELL_HEIGHT = 25;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Temporary until we get use an actual network call
    self.ivProfilePic.image = [UIImage imageNamed:@"coolGuy"];
    self.referrerName = @"John Doe";
    
    [self setTheme];
    [self setupCollectionView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.linkCollectionView reloadData];
    self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.height/2;
}


#pragma mark - IBActions

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(welcomeScreenActionButtonPressed:)]) {
        [self.delegate welcomeScreenActionButtonPressed:self.btnAction];
    }
}


#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.linkArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBLinkCell *linkCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"linkCell" forIndexPath:indexPath];
    [linkCell setupCellWithLinkName:self.linkArray[indexPath.row] tintColor:self.welcomeScreenAccent rowNum:indexPath.row];
    linkCell.delegate = self;
    return linkCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = [self.linkArray count] > 2 ? CGSizeMake(collectionView.frame.size.width, CELL_HEIGHT) : CGSizeMake(collectionView.frame.size.width/2, collectionView.frame.size.height);
    return cellSize;
}


#pragma mark - AMBLinkCell Delegate

- (void)buttonPressedAtIndex:(NSInteger)cellIndex {
    if ([self.delegate respondsToSelector:@selector(welcomeScreenLinkPressedAtIndex:)]) {
        [self.delegate welcomeScreenLinkPressedAtIndex:cellIndex];
    }
}


#pragma mark - UI Functions

- (void)setTheme {
    self.welcomeScreenAccent = self.parameters.accentColor;
    
    // Master View
    self.masterView.layer.cornerRadius = 6;
    
    // Image View
    self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.height/2;
    self.ivProfilePic.layer.borderColor = self.welcomeScreenAccent.CGColor;
    self.ivProfilePic.layer.borderWidth = 2;
    
    // Buttons
    self.btnClose.tintColor = self.welcomeScreenAccent;
    
    BOOL showButton = self.parameters.actionButtonTitle && ![self.parameters.actionButtonTitle isEqualToString:@""];
    if (!showButton) {
        self.buttonHeight.constant = 0;
        self.referralTextBottom.constant = 0;
    } else {
        [self.btnAction setTitle:self.parameters.actionButtonTitle forState:UIControlStateNormal];
        self.btnAction.backgroundColor = self.welcomeScreenAccent;
    }
    
    // Labels
    self.lblReferred.text = [self getCorrectString:self.parameters.referralMessage];
    self.lblDescription.text = self.parameters.detailMessage;
    self.linkArray = self.parameters.linkArray;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = [self.linkArray count] > 2 ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    [self.linkCollectionView setCollectionViewLayout:layout];
    self.linkCollectionView.scrollEnabled = [self.linkArray count] > 2 ? YES : NO;
    if ([self.linkArray count] > 2) { self.collectionViewHeight.constant = 100; }
}


#pragma mark - Helper Functions

- (NSString*)getCorrectString:(NSString*)string {
    BOOL containsNameValue = [self customContainsString:string subString:@"{{ name }}"];
    NSMutableString *newString = [NSMutableString stringWithString:string];
    
    if (containsNameValue) {
        [newString replaceOccurrencesOfString:@"{{ name }}" withString:self.referrerName options:0 range:NSMakeRange(0, [newString length])];
    }
    
    return newString;
}

// This method will only need to be used until we stop supporting iOS 7
- (BOOL)customContainsString:(NSString*)string subString:(NSString*)subString {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [string containsString:subString]; // This function will crash the app on iOS 7 or below
    } else {
        return [string rangeOfString:subString].location != NSNotFound;
    }
}

@end