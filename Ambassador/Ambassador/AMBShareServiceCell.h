//
//  ShareServiceCell.h
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBShareServiceCell : UICollectionViewCell

- (void)setUpCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon;
- (void)setupBorderCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon borderColor:(UIColor*)borderColor;

@end
