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
                               UITextViewDelegate, AMBUtilitiesDelegate, AMBContactLoaderDelegate, AMBUtilitiesDelegate>
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@property (weak, nonatomic) IBOutlet UIView *composeMessageView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnEditMessage;
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



//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeBoxWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeBoxHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * searchBarRightConstraint;

@property (strong, nonatomic) NSMutableSet *selected;
@property (strong, nonatomic) NSMutableArray *filteredData;
@property (nonatomic, strong) AMBContactLoader *contactLoader;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property BOOL activeSearch;
@property (nonatomic) BOOL isEditing;

@end

@implementation AMBContactSelector

NSString * const CONTACT_CELL_IDENTIFIER = @"contactCell";
NSString * const SELECTED_CELL_IDENTIFIER = @"selectedCell";

NSString * const NAME_PROMPT_SEGUE_IDENTIFIER = @"goToNamePrompt";

float const COMPOSE_MESSAGE_VIEW_HEIGHT = 100.0;
float const SEND_BUTTON_HEIGHT = 42.0;

float originalSendButtonHeight;


- (void)viewDidLoad
{
    [self registerForKeyboardNotifications];
    originalSendButtonHeight = self.sendButton.frame.size.height;
    
    self.title = self.prefs.navBarTitle;
    
    self.selected = [[NSMutableSet alloc] init];
    self.filteredData = [[NSMutableArray alloc] init];
    
    [[self.btnEditMessage imageView] setContentMode:UIViewContentModeScaleAspectFit];

    self.composeMessageTextView.textColor = [UIColor lightGrayColor];
    
    self.fadeView.hidden = YES;
    
    self.composeMessageTextView.text = self.defaultMessage;
    
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


#pragma mark - UI Functions

- (void)showOrHideSearchDoneButton {
    self.searchBarRightConstraint.constant = (self.searchBarRightConstraint.constant == 18) ? self.searchBarRightConstraint.constant + self.doneSearchingButton.frame.size.width + 18 : 18;
    [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    } completion:nil];
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
    [self showOrHideSearchDoneButton];
    sender.selected = NO;
    [self refreshAll];
}

- (IBAction)editMessageButton:(UIButton *)sender {
    if (!self.isEditing) {
        self.isEditing = YES;
        [self.composeMessageTextView becomeFirstResponder];
        self.composeMessageTextView.textColor = [UIColor blackColor];
    } else {
        self.isEditing = NO;
        [self.composeMessageTextView resignFirstResponder];
        self.composeMessageTextView.textColor = [UIColor lightGrayColor];
    }
}

- (void)refreshAll
{
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactsTable) {
        AMBContact *contact = self.activeSearch ? self.filteredData[indexPath.row] : self.data[indexPath.row];
        AMBContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // If the contact is ALREADY SELECTED
        if ([self.selected containsObject:contact]) {
            [self.selected removeObject:contact];
            [cell animateCheckmarkOut];
            [self refreshAll];
            return;
        }
        
        // If the contact is NOT SELECTED
        if ([self checkValidationForString:contact.value]) {
            [self.selected addObject:contact];
            [cell animateCheckmarkIn];
            [self refreshAll];
            return;
        }
        
        // If the contact is invalid
        [self showInvalidValueAlertForValue:contact.value];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactsTable) {
        AMBContact *contact = self.activeSearch ? self.filteredData[indexPath.row] : self.data[indexPath.row];
        AMBContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        [cell setUpCellWithContact:contact isSelected:[self.selected containsObject:contact]];
        
        return cell;
    } else {
        AMBContact *contact = [self.selected allObjects][indexPath.row];
        AMBSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECTED_CELL_IDENTIFIER];
        [cell setUpCellWithContact:contact];
        cell.delegate = self;
        
        return cell;
    }
}


#pragma mark - SelectedCellDelegate

- (void)removeButtonTappedForContact:(AMBContact *)contact {
    [self.selected removeObject:contact];
    [self refreshAll];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.searchBar) {
        [self showOrHideSearchDoneButton];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *fullSearchText =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.activeSearch = ([fullSearchText isEqualToString:@""]) ? NO : YES;
    [self searchWithText:fullSearchText];
    [self refreshAll];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}




#pragma mark - Keyboard Layout Adjustments
- (void)registerForKeyboardNotifications
{
    DLog();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)sender {
    if (self.isEditing) {
        CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.bottomViewBottomConstraint.constant = keyboardFrame.size.height;
        self.composeBoxHeight.constant = self.composeMessageView.frame.size.height - originalSendButtonHeight;
        self.sendButtonHeight.constant = 0;
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (self.bottomViewBottomConstraint.constant > 0) {
        self.bottomViewBottomConstraint.constant = 0;
        self.composeBoxHeight.constant = self.composeMessageView.frame.size.height + originalSendButtonHeight;
        self.sendButtonHeight.constant = originalSendButtonHeight;
        [self.view layoutIfNeeded];
    }
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
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
            } else {
                DLog(@"BulkShare SMS Success with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [self sendShareTrack:validatedNumbers];
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Message successfully shared!" withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
                [AMBUtilities sharedInstance].delegate = self;
            }
        }];
    } else {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid phone number. Please check and try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
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
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
            } else {
                DLog(@"BulkShare Email Success with Response Code - %li and Response - %@", (long)[httpResponse statusCode], [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [self sendShareTrack:validatedContacts];
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Message successfully shared!" withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
                [AMBUtilities sharedInstance].delegate = self;
            }
        }];
    } else {
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You may have selected an invalid email address. Please check and try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
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
            errorString = [NSString stringWithFormat:@"The phone number %@ is invalid.  Please change it to a valid phone number. \n(Example: 1-(555)555-5555, (555)555-5555, 555-5555)", valueString];
            
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

- (void)searchWithText:(NSString *)searchText {
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // Ignores any spacing before and after the string.. will NOT take out spaces
    
    NSArray *fullNameArray = [searchText componentsSeparatedByString:@" "];
    NSString *firstName = ([fullNameArray count] == 1) ? searchText : fullNameArray[0];
    NSString *lastName = ([fullNameArray count] == 1) ? searchText : fullNameArray[1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", firstName, lastName];
    self.filteredData = (NSMutableArray *)[self.data filteredArrayUsingPredicate:predicate];
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
    share.social_name = [AMBOptions serviceTypeStringValue:self.type];
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (error) {
            DLog(@"Error for BulkShareTrack %@ with ResponseCode %li and Response %@", [AMBOptions serviceTypeStringValue:self.type], (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        } else {
            DLog(@"Successfully shared BulkShareTrack %@ with ResponseCode %li and Response %@", [AMBOptions serviceTypeStringValue:self.type], (long)httpResponse.statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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


#pragma mark - AMBUtitlites Delegate

- (void)okayButtonClickedForUniqueID:(NSString *)uniqueID {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
