//
//  AMBWelcomeScreenViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenViewController.h"
#import "AMBWelcomeScreenViewController_Internal.h"
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

@end


@implementation AMBWelcomeScreenViewController

NSInteger const CELL_HEIGHT = 25;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ivProfilePic.image = self.referrerImage;
    
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
        [self.btnAction setTitle:[self getCorrectString:self.parameters.actionButtonTitle] forState:UIControlStateNormal];
        self.btnAction.backgroundColor = self.welcomeScreenAccent;
    }
    
    // Labels
    self.lblReferred.text = [self getCorrectString:self.parameters.referralMessage];
    self.lblDescription.text = [self getCorrectString:self.parameters.detailMessage];
    self.linkArray = [self getUpdatedLinkArray];
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
    // Creates a mutable string based on the string passed from params
    NSMutableString *newString = [NSMutableString stringWithString:string];

    while ([self customContainsString:newString subString:@"{{ name }}"]) {
        // Gets index of {{ name }}
        NSRange range = [newString rangeOfString:@"{{ name }}"];

        // Creates a mutable copy of the referrer name
        NSMutableString *mutableReferrerName = [[NSMutableString alloc] initWithString:self.referrerName];
        
        // Checks if we are using the default name value - 'An ambassador of COMPANY' - and checks where is it in the message to see if we should capitalize An or not
        if ([self usingReferrerDefaultValue] && [self nameIsMidSentence:newString charSpot:range.location]) {
            NSRange replaceRange = [mutableReferrerName rangeOfString:@"An"];
            [mutableReferrerName replaceOccurrencesOfString:@"An" withString:@"an" options:0 range:replaceRange];
        }
        
        newString = (NSMutableString*)[newString stringByReplacingCharactersInRange:range withString:mutableReferrerName];
    }
    
    return newString;
}

- (NSArray*)getUpdatedLinkArray {
    NSMutableArray *newLinkArray = [[NSMutableArray alloc] init];
    
    // Goes through each link and handles for {{ name }} in any them
    for (NSString *link in self.parameters.linkArray) {
        [newLinkArray addObject:[self getCorrectString:link]];
    }
    
    return newLinkArray;
}

// This method will only need to be used until we stop supporting iOS 7
- (BOOL)customContainsString:(NSString*)string subString:(NSString*)subString {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [string containsString:subString]; // This function will crash the app on iOS 7 or below
    } else {
        return [string rangeOfString:subString].location != NSNotFound;
    }
}

- (BOOL)nameIsMidSentence:(NSString*)text charSpot:(NSUInteger)spot {
    if (spot > 0) {
        int indexCheck = 1;
        
        NSString *charString = [NSString stringWithFormat:@"%c", [text characterAtIndex:spot - indexCheck]];
        
        // Keeps searching for the character before {{ name }} until it finds one that is not a " " value
        while ([charString isEqualToString:@" "]) {
            indexCheck++;
            charString = [NSString stringWithFormat:@"%c", [text characterAtIndex:spot - indexCheck]];
        }
        
        // If the character is not equal to one of the values in sentenceEnderString, then we can assume its in the middle of a sentence
        NSString *sentenceEnderString = @".?!";
        return [sentenceEnderString containsString:charString] ? NO : YES;
    }
    
    return NO;
}

- (BOOL)usingReferrerDefaultValue {
    return [self customContainsString:self.referrerName subString:@"An ambassador of"] ? YES : NO;
}

@end
