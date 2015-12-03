//
//  ContactCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBContact.h"

@interface AMBContactCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * name;
@property (nonatomic, weak) IBOutlet UILabel * value;
@property (nonatomic, weak) IBOutlet UIImageView * checkmarkView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * checkmarkConstraint;

- (void)setUpCellWithContact:(AMBContact*)contact isSelected:(BOOL)selected;

@end
