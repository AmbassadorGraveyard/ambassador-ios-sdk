//
//  SelectedCell.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBSelectedCell.h"

@implementation AMBSelectedCell


- (IBAction)removeButtonPressed:(UIButton *)sender
{
    [self.delegate removeButtonTappedForContact:self.selectedContact];
}

@end
