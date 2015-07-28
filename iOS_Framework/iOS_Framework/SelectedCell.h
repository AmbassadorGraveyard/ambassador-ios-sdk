//
//  SelectedCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoveButton.h"
#import "Contact.h"

@protocol SelectedCellDelegate <NSObject>

- (void)removeContact:(Contact *)contact;

@end


@interface SelectedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet RemoveButton *removeButton;
@property (weak) id<SelectedCellDelegate>delegate;

@end
