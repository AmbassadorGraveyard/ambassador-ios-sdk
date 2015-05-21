//
//  ReferAFriendCollectionViewController.m
//  ObjC
//
//  Created by Diplomat on 5/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ReferAFriendCollectionViewController.h"
#import "ReferAFriendCollectionViewCell.h"
@interface ReferAFriendCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property NSMutableArray* testPhotos;

@end

@implementation ReferAFriendCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        self.collectionView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 140,[[UIScreen mainScreen] bounds].size.width, 120);
        [self.collectionView registerClass:[ReferAFriendCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];

        //self.collectionView.delegate = self;
        //self.collectionView.dataSource = self;
        
        UIImage* image1 = [UIImage imageNamed:@"fb.png"];
        UIImage* image2 = [UIImage imageNamed:@"tw.png"];
        UIImage* image3 = [UIImage imageNamed:@"mail.png"];
        UIImage* image4 = [UIImage imageNamed:@"sms.png"];
        self.testPhotos = [NSMutableArray arrayWithObjects:image1, image2, image3, image4, nil];
        
        [self.collectionView reloadData];
        
        self.collectionView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UICollectionViewDataSource Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testPhotos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ReferAFriendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = self.testPhotos[indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"Photo: %ld", indexPath.row];
    return cell;
}


- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [[UICollectionReusableView alloc] init];
}


#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Touched item: %ld", indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Deselect Item
}


#pragma mark - UICollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

