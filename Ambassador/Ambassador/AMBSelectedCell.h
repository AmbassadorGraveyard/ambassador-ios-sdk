//
//  SelectedCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBContact.h"

@protocol AMBSelectedCellDelegate <NSObject>

- (void)removeButtonTappedForContact:(AMBContact *)contact;

@end


@interface AMBSelectedCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UIButton *removeButton;
@property (nonatomic, strong) AMBContact * selectedContact;
@property (weak) id<AMBSelectedCellDelegate>delegate;

- (void)setUpCellWithContact:(AMBContact*)contact;

@end
