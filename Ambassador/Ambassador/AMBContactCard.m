//
//  AMBContactCard.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/5/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBContactCard.h"

@interface AMBContactCard () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivContactPhoto;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UITableView * infoTableView;

@property (nonatomic, strong) NSMutableArray * valueArray;

@end

@implementation AMBContactCard


#pragma mark - LifeCycle

- (void)viewDidLoad {
    self.valueArray = [[NSMutableArray alloc] init];
    [self.valueArray addObjectsFromArray:self.contact.fullContact.phoneContacts];
    [self.valueArray addObjectsFromArray:self.contact.fullContact.emailContacts];
    [self setUpCard];
}


#pragma mark - UI Functions

- (void)setUpCard {
    self.ivContactPhoto.image = self.contact.contactImage;
    self.lblFullName.text = [self.contact fullName];
    self.infoTableView.backgroundColor = [UIColor clearColor];
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Removes empty cell from tableview
}


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.valueArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    AMBContact *contact = self.valueArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", contact.label, contact.value];
    cell.textLabel.textAlignment = NSTextAlignmentJustified;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    return cell;
}

@end
