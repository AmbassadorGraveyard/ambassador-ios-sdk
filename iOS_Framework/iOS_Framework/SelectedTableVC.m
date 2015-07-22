//
//  SelectedTableVC.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "SelectedTableVC.h"
#import "SelectedListTableCell.h"
#import "RemoveContactButton.h"
#import "Constants.h"
#import "Contact.h"
#import "Utilities.h"



#pragma mark - Local constants
float const SHARE_TABLE_TOP_CONSTANT = 60.0;

NSString * const SHARE_CELL_IDENTIFIER = @"selectedCell";
NSString * const SCREEN_TITLE = @"SELECTED CONTACTS";
NSString * const CLEAR_ALL_BUTTON_TITLE = @"CLEAR ALL";

float const SCREEN_TITLE_TOP_CONSTANT = 20.0;
float const SCREEN_TITLE_LEFT_CONSTANT = 15.0;
float const SCREEN_TITLE_RIGHT_CONSTANT = -90.0;
float const SCREEN_TITLE_HEIGHT_CONSTANT = 20.0;
#pragma mark -



@interface SelectedTableVC () <UITableViewDataSource, UITableViewDelegate>

@property UILabel *screenTitle;
@property UIButton *clearAllButton;

@end



@implementation SelectedTableVC

#pragma mark - Initialization
- (id)init
{
    DLog();
    if ([super init])
    {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    DLog();
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self setUpScreenTitle];
    [self setUpClearAllButton];
    [self setUpTableView];

}

- (void)setUpScreenTitle
{
    // Initialize properties
    self.screenTitle = [[UILabel alloc] init];
    self.screenTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.screenTitle.text = SCREEN_TITLE;
    self.screenTitle.font = DEFAULT_FONT();
    
    // Add to view hierarchy
    [self.view addSubview:self.screenTitle];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:SCREEN_TITLE_TOP_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:SCREEN_TITLE_LEFT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:SCREEN_TITLE_RIGHT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:SCREEN_TITLE_HEIGHT_CONSTANT]];
}

- (void)setUpClearAllButton
{
    // Initialize properties
    self.clearAllButton = [[UIButton alloc] init];
    self.clearAllButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearAllButton setTitle:CLEAR_ALL_BUTTON_TITLE forState:UIControlStateNormal];
    [self.clearAllButton addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearAllButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.clearAllButton.titleLabel.font = DEFAULT_FONT_SMALL();
    self.clearAllButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    // Add to view hierarchy
    [self.view addSubview:self.clearAllButton];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:SCREEN_TITLE_HEIGHT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:SCREEN_TITLE_RIGHT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-SCREEN_TITLE_LEFT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:SCREEN_TITLE_HEIGHT_CONSTANT]];
}

- (void)setUpTableView
{
    // Set Initial properties
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[SelectedListTableCell class] forCellReuseIdentifier:SHARE_CELL_IDENTIFIER];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Add to view hierarchy
    [self.view addSubview:self.tableView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:SHARE_TABLE_TOP_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
}



#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedCell" forIndexPath:indexPath];
    
    Contact *contact = self.data[indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ - %@", [contact firstName], [contact value]];
    
    
    RemoveContactButton * button = [[RemoveContactButton alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    [button setImage:imageFromBundleNamed(@"close.png") forState:UIControlStateNormal];
    button.indexPath = indexPath;
    // Set button value to the contact data so it can follow in selection
    button.value = self.data[indexPath.row];
    [button addTarget:self action:@selector(removeContact:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)removeContact:(UIButton *)button
{
    DLog();
    RemoveContactButton *removeButton = (RemoveContactButton *)button;
    if (removeButton)
    {
        [self.selected removeObject:removeButton.value];
        [self.delegate selectedContactsChanged];
    }
}

- (void)clearAll:(UIButton *)button
{
    DLog();
    [self.selected removeAllObjects];
    [self.delegate selectedContactsChanged];
}

@end
