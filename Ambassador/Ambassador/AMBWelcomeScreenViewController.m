//
//  AMBWelcomeScreenViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 2/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBWelcomeScreenViewController.h"
#import "AMBLinkCell.h"

@interface AMBWelcomeScreenViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivProfilePic;
@property (nonatomic, strong) IBOutlet UILabel * lblReferred;
@property (nonatomic, strong) IBOutlet UILabel * lblDescription;
@property (nonatomic, strong) IBOutlet UIButton * btnAction;
@property (nonatomic, strong) IBOutlet UICollectionView * linkCollectionView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * collectionViewHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * buttonHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * masterViewTop;

@property (nonatomic, strong) NSArray * linkArray;

@end


@implementation AMBWelcomeScreenViewController

NSInteger const CELL_HEIGHT = 25;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTheme];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://fraziercreative.agency/wp-content/uploads/2013/07/cool-guy.jpg"]];
    self.ivProfilePic.image = [UIImage imageWithData:imageData];
    self.masterViewTop.constant = -(self.masterViewTop.constant + self.masterView.frame.size.height);
    
    self.linkArray = @[@"Link Two", @"Link One"];
    [self setupCollectionView];
}

- (void)viewDidLayoutSubviews {
    if (self.masterViewTop.constant < 30) {
        self.masterViewTop.constant = 30;
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.4 animations:^{
                [self.view layoutIfNeeded];
                self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.height/2;
            }];
        } completion:nil];
    }
}


#pragma mark - IBActions

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.linkArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBLinkCell *linkCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"linkCell" forIndexPath:indexPath];
    [linkCell setupCellWithLinkName:self.linkArray[indexPath.row] tintColor:self.btnAction.backgroundColor];
    return linkCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = [self.linkArray count] > 2 ? CGSizeMake(collectionView.frame.size.width, CELL_HEIGHT) : CGSizeMake(collectionView.frame.size.width/2, collectionView.frame.size.height);
    return cellSize;
}


#pragma mark - UI Functions

- (void)setTheme {
    // Master View
    self.masterView.layer.cornerRadius = 6;
    
    // Image View
    self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.height/2;
    self.ivProfilePic.layer.borderColor = self.btnAction.backgroundColor.CGColor;
    self.ivProfilePic.layer.borderWidth = 2;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = [self.linkArray count] > 2 ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    [self.linkCollectionView setCollectionViewLayout:layout];
    self.linkCollectionView.scrollEnabled = [self.linkArray count] > 2 ? YES : NO;
    if ([self.linkArray count] > 2) { self.collectionViewHeight.constant = 100; }
}

@end
