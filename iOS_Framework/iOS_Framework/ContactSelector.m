//
//  ContactSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "ContactSelector.h"
#import "ContactCell.h"
#import "SelectedCell.h"
#import "Contact.h"
#import "Utilities.h"
#import "NamePrompt.h"
#import "ShareServicesConstants.h"
#import "Constants.h"

@interface ContactSelector () <UITableViewDataSource, UITableViewDelegate,
                               SelectedCellDelegate, UITextFieldDelegate,
                               NamePromptDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@property (weak, nonatomic) IBOutlet UIView *composeMessageView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *editMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *doneSearchingButton;
@property (weak, nonatomic) IBOutlet UITextView *composeMessageTextView;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

//iPad Specific
@property (weak, nonatomic) IBOutlet UITableView *selectedTable;
@property (weak, nonatomic) IBOutlet UILabel *selectedTableLabel;
//-------------

//Dynamic AutoLayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeBoxWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeBoxHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonHeight;

@property (strong, nonatomic) NSMutableSet *selected;
@property (strong, nonatomic) NSMutableArray *filteredData;

@property BOOL activeSearch;

@end

@implementation ContactSelector

NSString * const CONTACT_CELL_IDENTIFIER = @"contactCell";
NSString * const SELECTED_CELL_IDENTIFIER = @"selectedCell";

NSString * const NAME_PROMPT_SEGUE_IDENTIFIER = @"goToNamePrompt";

float const COMPOSE_MESSAGE_VIEW_HEIGHT = 123.0;
float const SEND_BUTTON_HEIGHT = 42.0;


- (void)viewDidLoad
{
    [self registerForKeyboardNotifications];

    // Set the navigation bar attributes (title and back button)
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [backButton setImage:imageFromBundleNamed(@"back.png") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.title = self.prefs.navBarTitle;
    
    self.selected = [[NSMutableSet alloc] init];
    self.filteredData = [[NSMutableArray alloc] init];
    
    self.contactsTable.delegate = self;
    self.contactsTable.dataSource = self;
    
    self.selectedTable.delegate = self;
    self.selectedTable.dataSource = self;
    
    self.searchBar.delegate = self;
    
    //self.composeMessageTextView.editable = NO;
    self.composeMessageTextView.textColor = [UIColor lightGrayColor];
    self.composeMessageTextView.delegate = self;
    self.editMessageButton.selected = NO;
    
    self.fadeView.hidden = YES;
    
    self.composeMessageTextView.text = self.defaultMessage;
    
    [self updateButton];
}
- (IBAction)sendButtonPressed:(UIButton *)sender
{
    if (self.selected.count > 0)
    {
        //TODO: validate short url is in there
        if (![self validateString:self.shortURL inString:self.composeMessageTextView.text])
        {
            NSString *message = [NSString stringWithFormat:@"Please include your url in the message: %@", self.shortURL];
            sendAlert(NO, message, self);
            return;
        }
        
        if ([self.serviceType isEqualToString:SMS_TITLE])
        {
            NSDictionary *ambassadorInfo = [[NSUserDefaults standardUserDefaults]
                                            dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
            NSMutableString *firstName = [NSMutableString stringWithString:@""];
            NSMutableString *lastName = [NSMutableString stringWithString:@""];
            
            firstName = ambassadorInfo[@"first_name"];
            lastName = ambassadorInfo[@"last_name"];
            
            firstName = (NSMutableString *)[firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            lastName = (NSMutableString *)[lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSLog(@"User first and last name: %@ %@", firstName, lastName);
            
            if ([firstName isEqualToString:@""] || [lastName isEqualToString:@""])
            {
                [self performSegueWithIdentifier:NAME_PROMPT_SEGUE_IDENTIFIER sender:self];
            }
            else
            {
                NSLog(@"Sending first and last name");
                [self sendSMSWithName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
            }
        }
        else if ([self.serviceType isEqualToString:EMAIL_TITLE])
        {
            [self sendEmail];
        }
    }
}

- (BOOL)validateString:(NSString *)string inString:(NSString *)inString
{
    return [inString rangeOfString:string].location != NSNotFound;
}

- (IBAction)clearAllButton:(UIButton *)sender
{
    DLog();
    
    [self.selected removeAllObjects];
    [self refreshAll];
}

- (IBAction)doneSearchingButton:(UIButton *)sender
{
    DLog();
    
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.activeSearch = NO;
    sender.selected = NO;
    [self refreshAll];
}

- (IBAction)editMessageButton:(UIButton *)sender
{
    DLog();
    //self.composeMessageTextView.editable = !self.composeMessageTextView.editable;
    if (self.editMessageButton.selected)
    {
        DLog();
        
        [self.composeMessageTextView resignFirstResponder];
    }
    else
    {
        DLog();
        
        [self.composeMessageTextView becomeFirstResponder];
    }
}

- (void)updateEditMessageButton
{
    DLog();
    self.editMessageButton.selected = !self.editMessageButton.selected;
    self.fadeView.hidden = !self.fadeView.hidden;
    if (!self.editMessageButton.selected)
    {
        DLog();
        
        self.composeMessageTextView.textColor = [UIColor lightGrayColor];
    }
    else
    {
        DLog();
        
        self.composeMessageTextView.textColor = [UIColor blackColor];
    }
}

- (void)refreshAll
{
    [self.contactsTable reloadData];
    [self.selectedTable reloadData];
    [self updateButton];
}

- (void)updateButton
{
    self.sendButton.enabled = self.selected.count? YES : NO;
    [self.sendButton setTitle:@"Select Contacts" forState:UIControlStateNormal];
    
    if (self.selected.count)
    {
        NSMutableString *buttonTitle = [NSMutableString stringWithFormat:@"Send to %i contact", (int)self.selected.count];
        if (self.selected.count > 1)
        {
            [buttonTitle appendString:@"s"];
        }
        [self.sendButton  setTitle:buttonTitle forState:UIControlStateNormal];
    }
}


#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.contactsTable)
    {
        Contact *contact = self.activeSearch? self.filteredData[indexPath.row] : self.data[indexPath.row];
        if ([self.selected member:contact])
        {
            [self.selected removeObject:contact];
        }
        else
        {
            [self.selected addObject:contact];
        }
    }
    if (tableView == self.selectedTable)
    {
        SelectedCell *cell = (SelectedCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self.selected removeObject:cell.removeButton.contact];
    }
    
    [self refreshAll];
}



#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.contactsTable)
    {
        if (self.activeSearch)
        {
            return self.filteredData.count;
        }
        
        return self.data.count;
    }
    else
    {
        return self.selected.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.contactsTable)
    {
        return [self tableView:tableView contactCellForRowAtIndexPath:indexPath];
    }
    else
    {
        return [self tableView:tableView selectedCellForRowAtIndexPath:indexPath];
    }
}



#pragma mark - ContactsTableView
- (UITableViewCell *)tableView:(UITableView *)tableView contactCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = self.activeSearch? self.filteredData[indexPath.row] : self.data[indexPath.row];
    
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
    cell.name.text = [contact fullName];
    cell.value.text = [NSString stringWithFormat:@"%@ - %@", contact.label, contact.value];
    
    if ([self.selected member:contact])
    {
         cell.checkmarkView.image = imageFromBundleNamed(@"check.png");
    }
    else
    {
        cell.checkmarkView.image = [[UIImage alloc] init];
    }
   
    return cell;
}



#pragma mark - SelectedTableView
- (UITableViewCell *)tableView:(UITableView *)tableView selectedCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = [self.selected allObjects][indexPath.row];
    
    SelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECTED_CELL_IDENTIFIER];
    cell.name.text = [NSString stringWithFormat:@"%@ - %@", contact.firstName, contact.value];
    cell.removeButton.contact = contact;
    cell.delegate = self;
    
    return cell;
}



#pragma mark - SelectedCellDelegate
- (void)removeContact:(Contact *)contact
{
    [self.selected removeObject:contact];
    [self refreshAll];
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setActiveSearchFlag:textField.text];
    self.doneSearchingButton.selected = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self setActiveSearchFlag:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *fullSearchText =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self setActiveSearchFlag:fullSearchText];

    [self searchWithText:fullSearchText];
    [self refreshAll];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.activeSearch = NO;
    textField.text = @"";
    [self refreshAll];
    
    return YES;
}

- (BOOL)setActiveSearchFlag:(NSString *)searchText
{
    DLog();
    
    self.activeSearch = [searchText isEqualToString:@""] ? NO : YES;
    self.doneSearchingButton.selected = self.activeSearch? YES : NO;
    return self.activeSearch;
}

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
        predicate = [NSPredicate
                     predicateWithFormat:@"(firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@) OR (firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@)",
                     firstName, lastName, lastName, firstName];
    }
    else
    {
        predicate = [NSPredicate
                     predicateWithFormat:@"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@",
                     firstName, lastName];
    }
    
    self.filteredData = (NSMutableArray *)[self.data filteredArrayUsingPredicate:predicate];
}


#pragma mark - Keyboard Layout Adjustments
- (void)registerForKeyboardNotifications
{
    DLog();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)sender
{
    DLog();
    
    // Animate compose box upward (and adjust to full width if iPad) and hide
    // the 'send to contacts' button
    if ([self.composeMessageTextView isFirstResponder])
    {
        [self updateEditMessageButton];
        
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        [self.view layoutIfNeeded];
        
        self.bottomViewBottomConstraint.constant = newFrame.size.height;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.composeBoxWidth.constant -= self.selectedTable.frame.size.width;
        }
        
        self.composeBoxHeight.constant = COMPOSE_MESSAGE_VIEW_HEIGHT - SEND_BUTTON_HEIGHT;
        self.sendButtonHeight.constant = 0;
    }

    NSTimeInterval duration = 0.0;
    float oldConstant = self.bottomViewBottomConstraint.constant;
    
    //Only animate slide slowly if full keyboard is appearing vs the sugguestion bar appearing
    duration = (ABS(self.bottomViewBottomConstraint.constant - oldConstant) < 100) ? 0.1 : 1.5;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    DLog();
    
    if ([self.composeMessageTextView isFirstResponder])
    {
        [self updateEditMessageButton];
    }
    
    // Restore the compose box to the bottom of the screen, un-hide 'send to
    // contacts' button and adjust the width if needed (on iPad)
    self.bottomViewBottomConstraint.constant = 0;
    self.composeBoxHeight.constant = COMPOSE_MESSAGE_VIEW_HEIGHT;
    self.sendButtonHeight.constant = SEND_BUTTON_HEIGHT;
    self.composeBoxWidth.constant = 0;

    NSTimeInterval duration = 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}



#pragma mark - NamePromptDelegate
- (void)sendSMSPressedWithName:(NSString *)name
{
    DLog();
    
    [self sendSMSWithName:name];
}

- (void)sendSMSWithName:(NSString *)name
{
    DLog();
    
    [self.delegate sendToContacts:[self.selected allObjects] forServiceType:SMS_TITLE fromName:name withMessage:self.composeMessageTextView.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sendEmail
{
    DLog();
    
    [self.delegate sendToContacts:[self.selected allObjects] forServiceType:EMAIL_TITLE fromName:@"" withMessage:self.composeMessageTextView.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - UITextViewDelegate
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    DLog();
//    
//    [self editMessageButton:self.editMessageButton];
//}



#pragma mark - Navigation
- (void)backButtonPressed:(UIButton *)button
{
    DLog();
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    DLog();
    
    if ([segue.identifier isEqualToString:NAME_PROMPT_SEGUE_IDENTIFIER])
    {
        NamePrompt *vc = (NamePrompt *)segue.destinationViewController;
        vc.delegate = self;
    }
}

@end
