//
//  SelectedCell.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "SelectedCell.h"

@implementation SelectedCell


- (IBAction)removeButtonPressed:(UIButton *)sender
{
    [self.delegate removeContact:self.removeButton.contact];
}

@end
