//
//  ContactsTableVC.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ContactsTableVC.h"
#import "ContactListTableCell.h"
#import "Constants.h"
#import "Contact.h"
#import "Utilities.h"



#pragma mark - Local Constants
CGRect SEARCH_ICON_FRAME()
{
    return CGRectMake(0, 0, 28, 14);
}

UIColor* TABLE_VIEW_GRAY_COLOR()
{
    return ColorFromRGB(233, 233, 233);
}

UIEdgeInsets CELL_SEPARATOR_INSETS()
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

NSString * const SEARCH_IMAGE_NAME = @"search.png";
NSString * const SEARCH_BAR_PLACEHOLDER_TEXT = @"Search Contacts";
NSString * const DONE_BUTTON_TEXT = @"DONE";
NSString * const CONTACTS_TABLE_CELL_IDENTIFIER = @"contactCell";

float const SEARCH_BAR_TOP_CONSTANT = 19.0;
float const SEARCH_BAR_LEFT_CONSTANT = 15.0;
float const SEARCH_BAR_RIGHT_CONSTANT = -15.0;
float const SEARCH_BAR_HEIGHT_CONSTANT = 32.0;

float const DONE_BUTTON_TOP_CONSTANT = 29.0;
float const DONE_BUTTON_RIGHT_CONSTANT = -15.0;
float const DONE_BUTTON_HEIGHT_CONSTANT = 12.0;
float const DONE_BUTTON_WIDTH_CONSTANT = 50.0;

float const TABLE_VIEW_TOP_CONSTANT = 70.0;
#pragma mark -



@interface ContactsTableVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property UITextField *searchBar;
@property UIButton *doneButton;
@property NSLayoutConstraint *searchBarRightPosition;
@property NSMutableArray *filteredData;
@property BOOL isActiveSearch;
@property BOOL isAddingNewNumber;
@end



@implementation ContactsTableVC

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
    
    self.navigationItem.title = AMB_RAF_SHARE_SERVICES_TITLE;
    
    self.view.backgroundColor = TABLE_VIEW_GRAY_COLOR();
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self setUpSearchBar];
    [self setUpDoneButton];
    [self setUpTableView];
}

- (void)setUpSearchBar
{
    // Initialize properties
    self.searchBar = [[UITextField alloc] init];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = SEARCH_BAR_PLACEHOLDER_TEXT;
    // Search icon view
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:SEARCH_ICON_FRAME()];
    searchIcon.image = imageFromBundleNamed(SEARCH_IMAGE_NAME);
    self.searchBar.leftView = searchIcon;
    self.searchBar.leftViewMode = UITextFieldViewModeAlways;

    // Add to view hierarchy
    [self.view addSubview:self.searchBar];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:SEARCH_BAR_TOP_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:SEARCH_BAR_LEFT_CONSTANT]];
    self.searchBarRightPosition = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:SEARCH_BAR_RIGHT_CONSTANT];
    [self.view addConstraint:self.searchBarRightPosition];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:SEARCH_BAR_HEIGHT_CONSTANT]];
}

- (void)setUpDoneButton
{
    // Initialize properties
    self.doneButton = [[UIButton alloc] init];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.doneButton setTitle:DONE_BUTTON_TEXT forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = DEFAULT_FONT_SMALL();
    self.doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.hidden = YES;
    
    // Add to view hierarchy
    [self.view addSubview:self.doneButton];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:DONE_BUTTON_TOP_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.0
                                                           constant:DONE_BUTTON_WIDTH_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:DONE_BUTTON_RIGHT_CONSTANT]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:DONE_BUTTON_HEIGHT_CONSTANT]];
}

- (void)setUpTableView
{
    // Initialize properties
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[ContactListTableCell class] forCellReuseIdentifier:CONTACTS_TABLE_CELL_IDENTIFIER];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView setSeparatorColor:TABLE_VIEW_GRAY_COLOR()];
    [self.tableView setSeparatorInset:CELL_SEPARATOR_INSETS()];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Add to view hierarchy
    [self.view addSubview:self.tableView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:TABLE_VIEW_TOP_CONSTANT]];
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
    ContactListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];

    Contact *contact;
    if (!self.isAddingNewNumber)// True if there is a non-empty array of results
    {
        // If there is text in the search bar return from the filtered array
        // else return from the full contact array
        contact = self.isActiveSearch ? self.filteredData[indexPath.row] : self.data[indexPath.row];
        
        cell.name.text = [contact fullName];
        cell.value.text = [NSString stringWithFormat:@"%@: %@", contact.label, contact.value];
        
        // Check if the value (phone number or email) is in the 'selected' set
        // if it is, add a check mark.
        if ([self.selected member:contact])
        {
            [self addCheckMarkOnCell:cell];
        }
        else
        {
            [self removeCheckmark:cell];
        }
        
        return cell;
    }
    
    // There are no results for the search string
    cell.name.text = @"No contacts found";
    cell.value.text = @"";
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isAddingNewNumber)// If we need to display "No contacts found" cell
    {
        return 1;
    }
    else if (self.isActiveSearch)// Use the array filtered  
    {
        return self.filteredData.count;
    }
    else
    {
        return self.data.count;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();
    
    Contact *contact;
    // Pull contact from filtered array if we are in an active search
    contact = self.isActiveSearch ? self.filteredData[indexPath.row] : self.data[indexPath.row];
    
    // Determine if contact should be added or removed from selected
    if ([self.selected member:contact])
    {
        [self.selected removeObject:contact];
    }
    else
    {
        [self.selected addObject:contact];
    }
    if (self.isActiveSearch)
    {
        self.searchBar.text = @"";
        [self textFieldShouldClear:self.searchBar];
    }
    
    [self.delegate selectedContactsChanged];
}

- (void)addCheckMarkOnCell:(ContactListTableCell *)cell
{
    UIImageView *accView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18.5, 13.5)];
    accView.image = imageFromBundleNamed(@"check.png");
    cell.accessoryView = accView;
}


- (void)removeCheckmark:(ContactListTableCell *)cell
{    
    UIImageView *accView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18.5, 13.5)];
    accView.image = [[UIImage alloc] init];
    cell.accessoryView = accView;
}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    DLog();
    
    [self setActiveSearchFlag:textField.text];
    
    // Shrink the text bar width to reveal a 'Done' button
    self.searchBarRightPosition.constant = -65.0;
    self.doneButton.hidden = NO;
    [UIView animateWithDuration:0.1 delay:0.0 options:0 animations:^{
        [self.searchBar layoutIfNeeded];
    } completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DLog();
    [textField resignFirstResponder];
    [self setActiveSearchFlag:textField.text];
    
    // Restore the width of the text field and hide 'Done' button
    self.doneButton.hidden = YES;
    self.searchBarRightPosition.constant = -15.0;
    [UIView animateKeyframesWithDuration:.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
             [self.searchBar layoutIfNeeded];
        }];
    } completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *fullSearchText =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self setActiveSearchFlag:fullSearchText];
    [self setAddingNewNumberFlag];
    [self searchWithText:fullSearchText];
    [self.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.isActiveSearch = NO;
    self.isAddingNewNumber = NO;
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)setActiveSearchFlag:(NSString *)searchText
{
    self.isActiveSearch = [searchText isEqualToString:@""] ? NO : YES;
    DLog(@"%i", self.isActiveSearch);
    return self.isActiveSearch;
}

- (BOOL)setAddingNewNumberFlag
{
    self.isAddingNewNumber = self.isActiveSearch && self.filteredData.count == 0;
    return self.isAddingNewNumber;
}



#pragma mark - Searching
- (void)searchWithText:(NSString *)searchText
{
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *array = [searchText componentsSeparatedByString:@" "];
    NSString *firstName = searchText;
    NSString *lastName = searchText;
    NSPredicate *predicate = nil;
    
    if ([array count] > 1)
    {
        firstName = array[0];
        lastName = array[1];
        predicate = [NSPredicate predicateWithFormat:@"(firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@) OR (firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@)", firstName, lastName, lastName, firstName];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", firstName, lastName];
    }
    
    self.filteredData = (NSMutableArray *)[self.data filteredArrayUsingPredicate:predicate];
    
    if (self.isActiveSearch)
    {
        self.isAddingNewNumber = (self.filteredData.count == 0) ? YES : NO;
    }
    else
    {
        self.isAddingNewNumber = NO;
    }
}



#pragma mark - Segues
- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(UIButton *)button
{
    [self textFieldDidEndEditing:self.searchBar];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
