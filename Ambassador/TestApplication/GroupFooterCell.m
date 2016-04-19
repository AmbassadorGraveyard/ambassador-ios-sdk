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

// Private properties
@property (nonatomic, strong) NSArray * selectedGroups;
@property (nonatomic, strong) UIViewController * parentViewController;

@end


@implementation GroupFooterCell

- (IBAction)saveTapped:(id)sender {
    [self.delegate groupFooterSaveButtonTappedWithGroups:self.selectedGroups];
}

- (IBAction)cancelTapped:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
