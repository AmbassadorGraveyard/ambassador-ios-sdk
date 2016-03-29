//
//  SocialCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SocialCell.h"

@interface SocialCell()

// IBOutlets
@property (nonatomic, strong) IBOutlet UILabel * lblSocialName;
@property (nonatomic, strong) IBOutlet UISwitch * swtEnabled;

// Private properties
@property (nonatomic) NSInteger orderIndex;

@end


@implementation SocialCell

#pragma mark - Setup Functions

- (void)setUpCellWithName:(NSString*)name isEnabled:(BOOL)enabled orderIndex:(NSInteger)index {
    // Cell
    self.preservesSuperviewLayoutMargins = NO;
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    self.orderIndex = index;
    
    // Label
    self.lblSocialName.text = name;
    
    // Switch
    self.swtEnabled.on = enabled;
    [self.swtEnabled addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
}


#pragma mark - Actions

/*
 Function gets called when the UI switch value
 is changed. Tells delegate about the switch 
 change.
 */
- (void)switchChanged {
    if ([self.delegate respondsToSelector:@selector(socialChannel:enableStatusUpdated:orderIndex:)]) {
        [self.delegate socialChannel:self.lblSocialName.text enableStatusUpdated:self.swtEnabled.isOn orderIndex:self.orderIndex];
    }
}

@end
