//
//  GroupFooterCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupFooterCellDelegate <NSObject>

- (void)groupFooterSaveButtonTappedWithGroups:(NSArray *)groups;

@end


@interface GroupFooterCell : UITableViewCell

@property (nonatomic, weak) id<GroupFooterCellDelegate> delegate;

@end
