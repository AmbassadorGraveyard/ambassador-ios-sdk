//
//  RAFCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAFItem.h"

@protocol RAFCellDelegate <NSObject>

- (void)RAFCellDeleteTappedForRAFItem:(RAFItem*)rafItem;
- (void)RAFCellExportTappedForRAFItem:(RAFItem*)rafItem;

@end


@interface RAFCell : UITableViewCell

@property (nonatomic) BOOL isEditing;
@property (nonatomic, weak) id<RAFCellDelegate> delegate;

- (void)setUpCellWithRaf:(RAFItem*)rafItem;
- (void)showSpinnerForExport;
- (void)stopSpinner;

@end
