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

@interface SelectedTableVC () <UITableViewDataSource, UITableViewDelegate>
@property UILabel *screenTitle;
@property UIButton *clearAllButton;
@end

@implementation SelectedTableVC

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
    
    self.screenTitle = [[UILabel alloc] init];
    self.screenTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.screenTitle.text = @"SELECTED CONTACTS";
    self.screenTitle.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:self.screenTitle];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:15.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-90.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenTitle
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:20.0]];

    self.clearAllButton = [[UIButton alloc] init];
    self.clearAllButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearAllButton setTitle:@"CLEAR ALL" forState:UIControlStateNormal];
    [self.clearAllButton addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearAllButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.clearAllButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.clearAllButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.clearAllButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-90.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-15.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.clearAllButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:20.0]];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[SelectedListTableCell class] forCellReuseIdentifier:@"selectedCell"];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:60.0]];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedCell" forIndexPath:indexPath];
    
    Contact *contact = self.data[indexPath.row];
    cell.name.text = [contact fullName];
    
    
    RemoveContactButton * button = [[RemoveContactButton alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    [button setImage:[UIImage imageNamed:@"close.png" inBundle:[NSBundle bundleWithIdentifier:@"com.ambassador.Framework"] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    button.indexPath = indexPath;
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

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    [self.delegate removeContact:self.data[indexPath.row]];
//}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
