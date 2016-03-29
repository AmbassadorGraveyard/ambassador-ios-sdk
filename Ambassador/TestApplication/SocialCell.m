//
//  SocialCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SocialCell.h"

@interface SocialCell()

@property (nonatomic, strong) IBOutlet UILabel * lblSocialName;
@property (nonatomic, strong) IBOutlet UISwitch * swtEnabled;

@end


@implementation SocialCell


#pragma mark - Setup Functions

- (void)setUpCellWithName:(NSString*)name isEnabled:(BOOL)enabled {
    // Cell
    self.preservesSuperviewLayoutMargins = NO;
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    
    // Label
    self.lblSocialName.text = name;
    
    // Switch
    self.swtEnabled.on = enabled;
}

@end
