//
//  GroupFooterCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "GroupFooterCell.h"

@interface GroupFooterCell()

// IBOutlets
@property (nonatomic, strong) IBOutlet UIButton * btnCancel;
@property (nonatomic, strong) IBOutlet UIButton * btnSave;

@end


@implementation GroupFooterCell


#pragma mark - IBActions

- (IBAction)saveTapped:(id)sender {
    [self.delegate groupFooterSaveButtonTapped];
}

- (IBAction)cancelTapped:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
