//
//  ReferAFriendCollectionViewCell.h
//  ObjC
//
//  Created by Diplomat on 5/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferAFriendCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *photo;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
