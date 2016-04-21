//
//  GroupFooterCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupFooterCellDelegate <NSObject>

- (void)groupFooterSaveButtonTapped;

@end


@interface GroupFooterCell : UITableViewCell

@property (nonatomic, strong) UIViewController * parentViewController;
@property (nonatomic, weak) id<GroupFooterCellDelegate> delegate;

@end
