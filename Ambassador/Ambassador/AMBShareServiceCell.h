//
//  ShareServiceCell.h
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBThemeManager.h"

@interface AMBShareServiceCell : UICollectionViewCell

@property (nonatomic) SocialShareTypes cellType;

- (void)setUpCellWithCellType:(SocialShareTypes)cellType;

@end
