//
//  AMB_ReferAFriendFullView.m
//  
//
//  Created by Diplomat on 5/28/15.
//
//

#import "AMB_ReferAFriendFullView.h"
#import "AMB_RAF_ShareServiceCell.h"

@interface AMB_ReferAFriendFullView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property NSArray *data;
@property UICollectionView *shareServices;
@property UICollectionViewFlowLayout *collectionViewLayout;
@property UILabel *header;

@end


@implementation AMB_ReferAFriendFullView

#pragma mark - Inits
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

- (id)init
{
    if ([super init])
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.view = [[UIView alloc] init];
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.itemSize = CGSizeMake(1, 1);
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.shareServices = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 25, screen.width, 25)
                                            collectionViewLayout:self.collectionViewLayout];
    self.shareServices.backgroundColor = [UIColor orangeColor];
    self.shareServices.dataSource = self;
    self.shareServices.delegate = self;
    [self.shareServices registerClass:[AMB_RAF_ShareServiceCell class] forCellWithReuseIdentifier:@"shareService"];
    [self.view addSubview:self.shareServices];
    [self.shareServices reloadData];
    
    self.data = @[ @"twitter", @"facebook", @"mail", @"message" ];
}


#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AMB_RAF_ShareServiceCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareService"
                                                                               forIndexPath:indexPath];
    cell.logo.text = self.data[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 25);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegateFlowLAyout

@end
