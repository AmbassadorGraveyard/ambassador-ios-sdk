//
//  AMBContactCard.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/5/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBContactCard.h"
#import "AMBThemeManager.h"

@interface AMBContactCard () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UIImageView * ivContactPhoto;
@property (nonatomic, strong) IBOutlet UIImageView * ivAvatarImage;
@property (nonatomic, strong) IBOutlet UILabel * lblFullName;
@property (nonatomic, strong) IBOutlet UITableView * infoTableView;
@property (nonatomic, strong) IBOutlet UIButton * btnClose;
@property (nonatomic, strong) IBOutlet UIView * buttonBackgroundView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * masterViewHeight;

@property (nonatomic, strong) UIView * fadeView;
@property (nonatomic, strong) NSMutableArray * valueArray;

@end

@implementation AMBContactCard

CGFloat const ROW_HEIGHT = 35;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    self.valueArray = [[NSMutableArray alloc] init];
    [self.valueArray addObjectsFromArray:self.contact.fullContact.phoneContacts];
    [self.valueArray addObjectsFromArray:self.contact.fullContact.emailContacts];
    [self setUpCard];
}

- (void)viewWillAppear:(BOOL)animated {
    self.fadeView = [[UIView alloc] initWithFrame:self.presentingViewController.view.frame];
    self.fadeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.77];
    self.fadeView.alpha = 0;
    [self.presentingViewController.view addSubview:self.fadeView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.fadeView.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView animateWithDuration:0.2 animations:^{
        self.fadeView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.fadeView removeFromSuperview];
    }];
}

- (void)viewDidLayoutSubviews {
    [self resizeMasterView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.fadeView.frame = self.presentingViewController.view.frame;
    [self resizeMasterView];
}


#pragma mark - IBActions

- (IBAction)buttonCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.valueArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    AMBContact *contact = self.valueArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", contact.label, contact.value];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    cell.textLabel.minimumScaleFactor = 0.6;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UI Functions

- (void)setUpCard {
    self.masterView.layer.cornerRadius = 5;
    self.lblFullName.text = [self.contact fullName];
    
    // Checks whether or not to show avatar image in case there is no contact photo
    self.ivAvatarImage.hidden = (self.contact.contactImage) ? YES : NO;
    if (!self.ivAvatarImage.hidden) { self.ivAvatarImage.image = [AMBValues imageFromBundleWithName:@"avatar" type:@"png" tintable:NO]; }
    
    // Sets the the contact photo and background color
    self.ivContactPhoto.image = self.contact.contactImage;
    self.ivContactPhoto.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    
    // Sets up tableView
    self.infoTableView.backgroundColor = [UIColor whiteColor];
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Removes empty cell from tableview
    
    [self.btnClose setImage:[AMBValues imageFromBundleWithName:@"close" type:@"png" tintable:YES] forState:UIControlStateNormal];
    self.btnClose.tintColor = [UIColor errorRed];
    self.buttonBackgroundView.layer.cornerRadius = self.buttonBackgroundView.frame.size.height/2;
    self.buttonBackgroundView.layer.borderWidth = 2;
    self.buttonBackgroundView.layer.borderColor = [UIColor errorRed].CGColor;
}

- (void)resizeMasterView {
    self.masterViewHeight.constant = self.ivContactPhoto.frame.size.height + self.lblFullName.frame.size.height + ([self.valueArray count] * ROW_HEIGHT) + 10;
}

@end
