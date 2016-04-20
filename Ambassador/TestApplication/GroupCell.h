//
//  GroupCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/20/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupObject.h"

@interface GroupCell : UITableViewCell

- (void)setUpCellWithGroup:(GroupObject *)group checkmarkVisible:(BOOL)visible;
- (void)fadeCheckmarkVisible:(BOOL)visible;

@end
