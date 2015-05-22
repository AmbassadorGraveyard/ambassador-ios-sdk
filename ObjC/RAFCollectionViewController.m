//
//  RAFCollectionViewController.m
//  AnalyticsApp
//
//  Created by Diplomat on 5/22/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "RAFCollectionViewController.h"
#import "RAFCollectionViewCell.h"
#import "CustomFlow.h"

@import Twitter;


//#import "RAFHeaderView.h"

@interface RAFCollectionViewController () <UICollectionViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property const NSArray* photos;
@property UILabel* header;


@end

@implementation RAFCollectionViewController

#pragma mark - Initialization
- (id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if ([super initWithCollectionViewLayout:layout]) {
        //Get Notifications of the device changing orientation to update views
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        
        //Allocating the UI Elements (collection view and the header)
        self.collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen]bounds] collectionViewLayout:layout];
        self.view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
        self.header = [[UILabel alloc] init];
        
        //Fill the icons (photos array)
        UIImage* facebookIMG = [UIImage imageNamed:@"fb.png"];
        UIImage* twitterIMG = [UIImage imageNamed:@"tw.png"];
        UIImage* emailIMG = [UIImage imageNamed:@"mail.png"];
        UIImage* smsIMG = [UIImage imageNamed:@"sms.png"];
        NSString* facebookTitle = @"Share";
        NSString* twitterTitle = @"Tweet";
        NSString* emailTitle = @"Send Email";
        NSString* smsTitle = @"Send Text";
        self.photos = @[
                       @{ @"image" : facebookIMG,
                          @"title" : facebookTitle
                        },
                       @{ @"image" : twitterIMG,
                          @"title" : twitterTitle
                        },
                       @{ @"image" : emailIMG,
                          @"title" : emailTitle
                        },
                       @{ @"image" : smsIMG,
                          @"title" : smsTitle
                          },
                       @{ @"image" : facebookIMG,
                          @"title" : facebookTitle
                          },
                       @{ @"image" : twitterIMG,
                          @"title" : twitterTitle
                          }
                       ];
        
        //Fill the titles;
        
        //set the collection view properties
        self.collectionView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.75];
        self.header.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.75];

        [self.collectionView registerClass:[RAFCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.header.text = @"REFER A FRIEND";
        self.header.textAlignment = NSTextAlignmentCenter;
        self.header.font = [UIFont fontWithName:@"System" size:30];
            }
    return self;
}

# pragma mark - Orientation View Refreshing
- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height / 2 - 40, [[UIScreen mainScreen] bounds].size.width, 60);
    self.header.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2 -80, [[UIScreen mainScreen] bounds].size.width, 40);
    
    [self.collectionView setNeedsDisplay];
    
    [self.view addSubview:self.header];
}

//Force redrawing of collection view to recalculate padding that centers cells
- (void)orientationChanged:(NSNotification*)notification {
    [self.collectionViewLayout invalidateLayout];
}


#pragma mark - CollectionViewDataSource Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RAFCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.image.image = self.photos[indexPath.row][@"image"];
    
    //cell.label.text =  self.photos[indexPath.row][@"title"];
    //cell.contentView.layer.borderWidth = 1;
    //cell.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item: %ld", (long)indexPath.row);
    
    if (indexPath.row == 0) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        if ( YES || [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [controller setInitialText:@"Check out this thingy: http://blahblahblah.com"];
            [[self presentingViewController] presentViewController:controller animated:YES completion:nil];
        }
        
    } else if (indexPath.row == 1) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        if (YES || [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [controller setInitialText:@"Check out this thingy: http://blahblahblah.com"];
            [[self presentingViewController] presentViewController:controller animated:YES completion:nil];
        }
    } else if (indexPath.row == 2) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        MFMailComposeViewController* controller =[[MFMailComposeViewController alloc] init];
        [controller setSubject:@"Check out this thingy!"];
        [controller setMessageBody:@"http://blahblahblah.com" isHTML:NO];
        controller.mailComposeDelegate = self;
        [[self presentingViewController] presentViewController:controller animated:YES completion:nil];
    } else if (indexPath.row == 3) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.messageComposeDelegate = self;
            controller.body = @"Check out this thingy: http://blahblahblah.com";
            [[self presentingViewController] presentViewController:controller animated:YES completion:nil];

        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(36, 36);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    //Dynamically calculate amount of left padding to center the cells
    if ([[UIScreen mainScreen] bounds].size.width > self.photos.count * 36 + 15 * (self.photos.count - 1)) {
        float padding = ([[UIScreen mainScreen] bounds].size.width - (self.photos.count * 36 + 15 * (self.photos.count - 1))) / 2;
        return UIEdgeInsetsMake(10, padding, 10, 0);
    }

    return UIEdgeInsetsMake(10, 10, 10, 0);
}

@end
