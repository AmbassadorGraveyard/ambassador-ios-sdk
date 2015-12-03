//
//  SelectedCell.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBSelectedCell.h"

@implementation AMBSelectedCell

#pragma mark - Setup Functionality

- (void)setUpCellWithContact:(AMBContact*)contact {
    self.selectedContact = contact;
    self.name.text = [NSString stringWithFormat:@"%@ - %@", contact.firstName, contact.value];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


#pragma mark - IBActions

- (IBAction)removeButtonPressed:(UIButton *)sender {
    [self.delegate removeButtonTappedForContact:self.selectedContact];
}

@end
