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
@property NSMutableArray *apiResponse;
@property UICollectionView *shareServices;
@property UICollectionViewFlowLayout *collectionViewLayout;
@property UILabel *headerTitle;
@property UILabel *headerDescription;
@property UIView *shareServiceWrapper;

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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    
    /*
    ------------------------
    Main View initialization
    ------------------------
    */
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    /*
     ---------------------------
     Header title initialization
     ---------------------------
     */
    self.headerTitle = [UILabel new];
    self.headerTitle.text = @"header title";
    self.headerTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:25];
    self.headerTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerTitle];
    
    self.headerDescription = [UILabel new];
    self.headerDescription.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerDescription];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerTitle
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.headerDescription
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:-10.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerTitle
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    /*
    ---------------------------------
    Header description initialization
    ---------------------------------
    */

    self.headerDescription.numberOfLines = 0;
    self.headerDescription.textAlignment = NSTextAlignmentCenter;
    self.headerDescription.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.headerDescription.text = @"fdjsdfjdls;kfajds;lfkadjfskldsakfjadsl;fja  dsfsdfkjasdl;kfjasdfkl;asdf j;lakdsfjasdlfjasd;lfjadslfjasdlf;jasdfl;dsjfld;safj;adsljfads;lfjadls;fjads;fkljsad;lkfjasd;lfkjds";

//    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerDescription
//                                                           attribute:NSLayoutAttributeTop
//                                                           relatedBy:NSLayoutRelationEqual
//                                                              toItem:self.headerTitle
//                                                           attribute:NSLayoutAttributeBottom
//                                                          multiplier:1.0
//                                                            constant:10.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerDescription
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerDescription
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.headerDescription
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.9
                                                            constant:0.0]];
    
    /*
    ------------------------------------
    CollectionView layout initialization
    ------------------------------------
    */
    self.collectionViewLayout = [UICollectionViewFlowLayout new];
    self.collectionViewLayout.itemSize = CGSizeMake(36, 36);
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    /*
    ------------------------------------
    Share service wrapper initialization
    ------------------------------------
    */
    self.shareServiceWrapper = [UIView new];
    self.shareServiceWrapper.backgroundColor = [UIColor clearColor];
    self.shareServiceWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.shareServiceWrapper];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.shareServiceWrapper
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.headerDescription
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:20.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.shareServiceWrapper
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.shareServiceWrapper
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.9
                                                            constant:0.0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.shareServiceWrapper attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.shareServiceWrapper attribute:NSLayoutAttributeTop multiplier:1.0 constant:36.0]];
    
    
    /*
    ----------------------------
    Share service initialization
    ----------------------------
    */
    self.shareServices = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 25, 36)
                                            collectionViewLayout:self.collectionViewLayout];
    self.shareServices.backgroundColor = [UIColor clearColor];
    self.shareServices.dataSource = self;
    self.shareServices.delegate = self;
    [self.shareServices sizeToFit];
    [self.shareServices registerClass:[AMB_RAF_ShareServiceCell class] forCellWithReuseIdentifier:@"shareServiceCell"];
    [self.shareServiceWrapper addSubview:self.shareServices];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/services"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *e;
        NSMutableArray * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        if (!e)
        {
            self.apiResponse = json;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.shareServices reloadData];
            });
        }
    }] resume];
   
}


#pragma mark - Orientation Change Compensation
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGSize superviewSize = [[UIScreen mainScreen] bounds].size;
    //[self.shareServices sizeToFit];
    self.shareServices.frame = CGRectMake(0, 0, superviewSize.width * 0.9, 36);
    [self.view setNeedsDisplay];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDelegate



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.apiResponse.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AMB_RAF_ShareServiceCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareServiceCell"
                                                                               forIndexPath:indexPath];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:self.apiResponse[indexPath.row][@"image"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.logo.image = [UIImage imageWithData:data];
            //[self.shareServices reloadData];
        });
    }] resume];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - UICollectionViewDelegateFlowLAyout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(36, 36);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width * 0.9;
    CGFloat contentWidth = self.collectionViewLayout.itemSize.width * 5 + self.collectionViewLayout.minimumInteritemSpacing * 4;
    CGFloat padding = 0.0;
    if (contentWidth < screenWidth) {
        padding = (screenWidth - contentWidth) / 2;
    }
    return UIEdgeInsetsMake(0, padding, 0, 0);
}

@end
