//
//  AMBLinkCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/1/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMBLinkCellDelegate <NSObject>

- (void)buttonPressedAtIndex:(NSInteger)cellIndex;

@end


@interface AMBLinkCell : UICollectionViewCell

@property (nonatomic, weak) id<AMBLinkCellDelegate> delegate;

- (void)setupCellWithLinkName:(NSString*)linkName tintColor:(UIColor*)tintColor rowNum:(NSInteger)rowNum;

@end
