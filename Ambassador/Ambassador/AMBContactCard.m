//
//  AMBContactCard.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/5/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBContactCard.h"

@interface AMBContactCard ()

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivContactPhoto;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UITableView * infoTableView;

@end

@implementation AMBContactCard


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setUpCard];
}


#pragma mark - UI Functions

- (void)setUpCard {
    self.ivContactPhoto.image = self.contact.contactImage;
    self.lblFullName.text = [self.contact fullName];
}

@end
