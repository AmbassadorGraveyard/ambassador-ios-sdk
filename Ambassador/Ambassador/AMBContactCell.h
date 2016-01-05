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

// IBOutlets
@property (nonatomic, weak) IBOutlet UILabel * name;
@property (nonatomic, weak) IBOutlet UILabel * value;
@property (nonatomic, weak) IBOutlet UIImageView * checkmarkView;
@property (nonatomic, weak) IBOutlet UIImageView * contactPhoto;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * checkmarkConstraint;

// Other properties
@property (nonatomic, weak) AMBContact * contact;
@property (nonatomic, weak) id <AMBContactCellDelegate> delegate;

- (void)setUpCellWithContact:(AMBContact*)contact isSelected:(BOOL)selected;
- (void)animateCheckmarkIn;
- (void)animateCheckmarkOut;

@end
