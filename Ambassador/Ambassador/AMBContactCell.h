//
//  ContactCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBContact.h"

@protocol AMBContactCellDelegate <NSObject>

- (void)longPressTriggeredForContact:(AMBContact*)contact;

@end


@interface AMBContactCell : UITableViewCell

// Other properties
@property (nonatomic, weak) AMBContact * contact;
@property (nonatomic, weak) id <AMBContactCellDelegate> delegate;

- (void)setUpCellWithContact:(AMBContact*)contact isSelected:(BOOL)selected;
- (void)animateCheckmarkIn;
- (void)animateCheckmarkOut;

@end
