//
//  RAFCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAFItem.h"

@interface RAFCell : UITableViewCell

- (void)setUpCellWithRaf:(RAFItem*)rafItem;

@end
