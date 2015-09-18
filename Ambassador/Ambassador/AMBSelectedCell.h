//
//  SelectedCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBRemoveButton.h"
#import "AMBContact.h"

@protocol AMBSelectedCellDelegate <NSObject>

- (void)removeContact:(AMBContact *)contact;

@end


@interface AMBSelectedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet AMBRemoveButton *removeButton;
@property (weak) id<AMBSelectedCellDelegate>delegate;

@end
