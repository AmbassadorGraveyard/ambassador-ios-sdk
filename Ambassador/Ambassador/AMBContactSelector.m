//
//  ContactSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBContactSelector.h"
#import "AMBContactCell.h"
#import "AMBSelectedCell.h"
#import "AMBContact.h"
#import "AMBUtilities.h"
#import "AMBNamePrompt.h"
#import "AMBShareServicesConstants.h"
#import "AMBConstants.h"
#import "AMBThemeManager.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBAmbassadorNetworkManager.h"
#import "AMBNetworkObject.h"
#import "AMBBulkShareHelper.h"
#import "AMBOptions.h"
#import "AMBContactLoader.h"

@interface AMBContactSelector () <UITableViewDataSource, UITableViewDelegate,
                               AMBSelectedCellDelegate, UITextFieldDelegate,
                               UITextViewDelegate, AMBUtilitiesDelegate, AMBContactLoaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@property (weak, nonatomic) IBOutlet UIView *composeMessageView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *editMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *doneSearchingButton;
@property (weak, nonatomic) IBOutlet UITextView *composeMessageTextView;
@property (weak, nonatomic) IBOutlet UIView *fadeView;
@property (weak, nonatomic) IBOutlet UIView * containerView;

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
@property (nonatomic, strong) AMBContactLoader *contactLoader;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property BOOL activeSearch;

@end

@implementation AMBContactSelector

NSString * const CONTACT_CELL_IDENTIFIER = @"contactCell";
NSString * const SELECTED_CELL_IDENTIFIER = @"selectedCell";

NSString * const NAME_PROMPT_SEGUE_IDENTIFIER = @"goToNamePrompt";

float const COMPOSE_MESSAGE_VIEW_HEIGHT = 100.0;
float const SEND_BUTTON_HEIGHT = 42.0;


- (void)viewDidLoad
{
    [self registerForKeyboardNotifications];

    // Set the navigation bar attributes (title and back button)
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [backButton setImage:[AMBimageFromBundleNamed(@"back", @"png") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
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
    
    [self.editMessageButton setImage:AMBimageFromBundleNamed(@"pencil", @"png") forState:UIControlStateNormal];
    [self.editMessageButton setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
    
    //self.composeMessageTextView.editable = NO;
    self.composeMessageTextView.textColor = [UIColor lightGrayColor];
    self.composeMessageTextView.delegate = self;
    self.editMessageButton.selected = NO;
    
    self.fadeView.hidden = YES;
    
    self.composeMessageTextView.text = self.defaultMessage;
    [self.composeMessageTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(viewDidAppear:) forControlEvents:UIControlEventValueChanged];
    [self.contactsTable addSubview:self.refreshControl];
    
    [self updateButton];
    [self setUpTheme];
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshContacts];
    [self.contactsTable reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)setUpTheme {
    self.containerView.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSearchBackgroundColor];
    [self.doneSearchingButton setTitleColor:[[AMBThemeManager sharedInstance] colorForKey:ContactSearchDoneButtonTextColor] forState:UIControlStateNormal];

    self.sendButton.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    [self.sendButton.titleLabel setFont:[[AMBThemeManager sharedInstance] fontForKey:ContactSendButtonTextFont]];
}


#pragma mark - IBActions

- (IBAction)sendButtonPressed:(UIButton *)sender {
    if (self.selected.count > 0)
    {
        //TODO: validate short url is in there
        if (![self validateString:self.shortURL inString:self.composeMessageTextView.text]){
            NSString *message = [NSString stringWithFormat:@"Please include your url in the message: %@", self.shortURL];
            AMBsendAlert(NO, message, self);
            return;
        }

        switch (self.type) {
            case AMBSocialServiceTypeEmail:
                [self sendEmail];
                break;
                
            case AMBSocialServiceTypeSMS:
                if ([self alreadyHaveNames]) {
                    [self sendSMS];
                } else {
                    [self performSegueWithIdentifier:NAME_PROMPT_SEGUE_IDENTIFIER sender:self];
                }
                
                break;
                
            default:
                break;
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
        AMBContact *contact = self.activeSearch? self.filteredData[indexPath.row] : self.data[indexPath.row];
        if ([self.selected member:contact])
        {
            [self.selected removeObject:contact];
        }
        else
        {
            if ([self checkValidationForString:contact.value]) {
                [self.selected addObject:contact];
            } else {
                [self showInvalidValueAlertForValue:contact.value];
            }
        }
    }
    if (tableView == self.selectedTable)
    {
        AMBSelectedCell *cell = (AMBSelectedCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    AMBContact *contact = self.activeSearch? self.filteredData[indexPath.row] : self.data[indexPath.row];
    
    AMBContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
    cell.name.text = [contact fullName];
    cell.name.font = [[AMBThemeManager sharedInstance] fontForKey:ContactTableNameTextFont];
    cell.value.text = [NSString stringWithFormat:@"%@ - %@", contact.label, contact.value];
    cell.value.font = [[AMBThemeManager sharedInstance] fontForKey:ContactTableInfoTextFont];
    
    if ([self.selected member:contact])
    {
        cell.checkmarkView.image = [AMBimageFromBundleNamed(@"check", @"png") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.checkmarkView.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactTableCheckMarkColor];
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
    AMBContact *contact = [self.selected allObjects][indexPath.row];
    
    AMBSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECTED_CELL_IDENTIFIER];
    cell.name.text = [NSString stringWithFormat:@"%@ - %@", contact.firstName, contact.value];
    cell.removeButton.contact = contact;
    cell.delegate = self;
    
    return cell;
}



#pragma mark - SelectedCellDelegate
- (void)removeContact:(AMBContact *)contact
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
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        [self.view layoutIfNeeded];
        
        if (ABS(self.bottomViewBottomConstraint.constant - frame.size.height) > 100)
        {
            [self updateEditMessageButton];
        }
        
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


#pragma mark - Send Functions

- (void)sendSMS {
    NSArray *validatedNumbers = [AMBBulkShareHelper validatedPhoneNumbers:[self.selected allObjects]];
    
    if (validatedNumbers.count > 0) {
        NSMutableString *firstName = [[NSMutableString alloc] initWithString:[AmbassadorSDK sharedInstance].user.first_name];
        NSMutableString *lastName = [[NSMutableString alloc] initWithString:[AmbassadorSDK sharedInstance].user.last_name];
        
        firstName = (NSMutableString *)[firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lastName = (NSMutableString *)[lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *senderName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        AMBBulkShareSMSObject *smsObject = [[AMBBulkShareSMSObject alloc] initWithPhoneNumbers:validatedNumbers fromSender:senderName message:self.composeMessageTextView.text];
        
        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:smsObject url:[AMBAmbassadorNetworkManager bulkShareSMSUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (error) {
                DLog(@"Error for BulkShare SMS with Response Code - %li and Response - %@", (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." forViewController:self];
            } else {
                DLog(@"BulkShare SMS Success with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [self sendShareTrack:validatedNumbers];
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Message successfully shared!" forViewController:self];
                [AMBUtilities sharedInstance].delegate = self;
            }
        }];
    } else {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid phone number. Please check and try again." forViewController:self];
    }
}

- (void)sendEmail {
    NSArray *validatedContacts = [AMBBulkShareHelper validatedEmails:[self.selected allObjects]]; // Validate the contact list for emails

    if (validatedContacts.count > 0) {
        AMBBulkShareEmailObject *emailObject = [[AMBBulkShareEmailObject alloc] initWithEmails:validatedContacts
           shortCode:self.urlNetworkObject.short_code message:self.composeMessageTextView.text subjectLine:self.urlNetworkObject.subject];
        
        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:emailObject url:[AMBAmbassadorNetworkManager bulkShareEmailUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (error) {
                DLog(@"Error for BulkShare Email with Response Code - %li and Response - %@", (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." forViewController:self];
            } else {
                DLog(@"BulkShare Email Success with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [self sendShareTrack:validatedContacts];
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Message successfully shared!" forViewController:self];
                [AMBUtilities sharedInstance].delegate = self;
            }
        }];
    } else {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid email address. Please check and try again." forViewController:self];
    }
}

#pragma mark - Helper Functions

- (BOOL)alreadyHaveNames {
    NSMutableString *firstName = [[NSMutableString alloc] initWithString:[AmbassadorSDK sharedInstance].user.first_name];
    NSMutableString *lastName = [[NSMutableString alloc] initWithString:[AmbassadorSDK sharedInstance].user.last_name];
    
    firstName = (NSMutableString *)[firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    lastName = (NSMutableString *)[lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([firstName isEqualToString:@""] || [lastName isEqualToString:@""]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkValidationForString:(NSString*)valueString {
    switch (self.type) {
        case AMBSocialServiceTypeEmail:
            return [AMBBulkShareHelper isValidEmail:valueString];
            
        case AMBSocialServiceTypeSMS: {
            NSString *strippedString = [AMBBulkShareHelper stripPhoneNumber:valueString];
            return [AMBBulkShareHelper isValidPhoneNumber:strippedString];
        }
            
        default:
            return NO;
    }
}

- (void)showInvalidValueAlertForValue:(NSString*)valueString {
    NSString *errorString;
    
    switch (self.type) {
        case AMBSocialServiceTypeEmail:
            errorString = [NSString stringWithFormat:@"The email address %@ is invalid.  Please change it to a valid email address. \n(Example: user.name@example.com)", valueString];
            break;
            
        case AMBSocialServiceTypeSMS:
            errorString = [NSString stringWithFormat:@"The phone number %@ is invalid.  Please changed it to a valid phone number. \n(Example: 555-555-5555, 1-555-555-5555, 555-5555)", valueString];
            
        default:
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to select!" message:errorString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
}

- (void)refreshContacts {
    self.contactLoader = [[AMBContactLoader alloc] initWithDelegate:self];
    
    switch (self.type) {
        case AMBSocialServiceTypeEmail:
            self.data = self.contactLoader.emailAddresses;
            break;
        case AMBSocialServiceTypeSMS:
            self.data = self.contactLoader.phoneNumbers;
            break;
        default:
            break;
    }
}


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
        AMBNamePrompt *vc = (AMBNamePrompt *)segue.destinationViewController;
        vc.delegate = self;
    }
}


#pragma mark - Share Track 

- (void)sendShareTrack:(NSArray *)contacts {
    AMBShareTrackNetworkObject *share = [[AMBShareTrackNetworkObject alloc] init];
    if (self.type == AMBSocialServiceTypeEmail) {
        share.recipient_email = [self valuesFromContacts:[self.selected allObjects]];
    } else if (self.type == AMBSocialServiceTypeSMS) {
        share.recipient_username = [self validatePhoneNumbers:[self.selected allObjects]];
    }
    share.short_code = self.urlNetworkObject.short_code;
    share.social_name = socialServiceTypeStringVal(self.type);
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (error) {
            DLog(@"Error for BulkShareTrack %@ with ResponseCode %li and Response %@", socialServiceTypeStringVal(self.type), (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        } else {
            DLog(@"Successfully shared BulkShareTrack %@ with ResponseCode %li and Response %@", socialServiceTypeStringVal(self.type), (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        }
    }];
}

- (NSMutableArray *)valuesFromContacts:(NSArray *)contacts {
    NSMutableArray *returnVal = [[NSMutableArray alloc] init];
    for (AMBContact *contact in contacts) {
        [returnVal addObject:contact.value];
    }
    return returnVal;
}


- (NSMutableArray *)validatePhoneNumbers:(NSArray *)contacts {
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    for (AMBContact *contact in contacts) {
        NSString *number = [[contact.value componentsSeparatedByCharactersInSet:
                             [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]]
                            componentsJoinedByString:@""];
        if (number.length == 11 || number.length == 10 || number.length == 7) {
            [validSet addObject:number];
        }
    }
    return validSet;
}


#pragma mark - AMBUtilites Delegate

- (void)okayButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - AMBNamePrompt Delegate 

- (void)namesUpdatedSuccessfully {
    [self sendSMS];
}


#pragma mark - AMBContactLoader Delegate

- (void)contactsFailedToLoadWithError:(NSString *)errorTitle message:(NSString *)message {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to load contacts" message:@"There was an error loading your contact list." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [errorAlert show];
    
    DLog(@"Error loading contacts - %@", message);
}

@end
