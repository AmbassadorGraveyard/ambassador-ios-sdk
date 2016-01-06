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
#import "AMBNamePrompt.h"
#import "AMBThemeManager.h"
#import "AMBAmbassadorNetworkManager.h"
#import "AMBNetworkObject.h"
#import "AMBBulkShareHelper.h"
#import "AMBOptions.h"
#import "AMBContactLoader.h"
#import "AMBContactCard.h"

@interface AMBContactSelector () <UITableViewDataSource, UITableViewDelegate,
                                AMBSelectedCellDelegate, UITextFieldDelegate,
                                UITextViewDelegate, AMBUtilitiesDelegate, AMBContactLoaderDelegate,
                                AMBUtilitiesDelegate, UIGestureRecognizerDelegate, AMBNamePromptDelegate, AMBContactCellDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UITableView *contactsTable;
@property (nonatomic, strong) IBOutlet UIView *composeMessageView;
@property (nonatomic, strong) IBOutlet UITextField *searchBar;
@property (nonatomic, strong) IBOutlet UIButton *btnEditMessage;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet UIButton *doneSearchingButton;
@property (nonatomic, strong) IBOutlet UITextView *composeMessageTextView;
@property (nonatomic, strong) IBOutlet UIView * containerView;
@property (nonatomic, strong) IBOutlet UIView * searchFieldBackground;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *composeBoxHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *sendButtonHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * searchBarRightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * contactTableBottomConstraint;
@property (nonatomic, strong) IBOutlet UITableView *selectedTable; // iPad Specific

// Properties
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableSet *selected;
@property (nonatomic, strong) NSMutableArray *filteredData;
@property (nonatomic, strong) AMBContactLoader *contactLoader;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView * fadeView;
@property (nonatomic, strong) AMBContact * selectedContact;
@property (nonatomic) BOOL activeSearch;
@property (nonatomic) BOOL isEditing;

@end


@implementation AMBContactSelector

NSString * const NAME_PROMPT_SEGUE_IDENTIFIER = @"goToNamePrompt";
NSString * const CONTACT_CARD_SEGUE_IDENTIFIER = @"contactCardSegue";
float originalSendButtonHeight;
BOOL keyboardShowing = NO;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    [self registerForKeyboardNotifications];
    originalSendButtonHeight = self.sendButton.frame.size.height;
    self.title = self.prefs.navBarTitle;
    self.selected = [[NSMutableSet alloc] init];
    self.filteredData = [[NSMutableArray alloc] init];
    self.composeMessageTextView.text = self.defaultMessage;
    [self setUpTheme];
    [[AMBContactLoader sharedInstance] attemptLoadWithDelegate:self loadingFromCache:^(BOOL isCached) {
        if (!isCached) {
            [[AMBUtilities sharedInstance] showLoadingScreenForView:self.view];
        }
    }];

    // Sets up a 'Pull to refresh'
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.contactsTable addSubview:self.refreshControl];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView animateWithDuration:.1 animations:^{
        self.fadeView.frame = self.containerView.frame;
    }];
    
    if ([self.fadeView isDescendantOfView:self.containerView]) {
        [self.containerView bringSubviewToFront:self.fadeView];
        [self.containerView bringSubviewToFront:self.composeMessageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
}


#pragma mark - UI Functions

- (void)setUpTheme {
    self.searchFieldBackground.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSearchBackgroundColor];
    [self.doneSearchingButton setTitleColor:[[AMBThemeManager sharedInstance] colorForKey:ContactSearchDoneButtonTextColor] forState:UIControlStateNormal];
    self.composeMessageTextView.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    self.searchBar.tintColor = [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor];
    
    self.navigationController.navigationBar.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
    [self.sendButton.titleLabel setFont:[[AMBThemeManager sharedInstance] fontForKey:ContactSendButtonTextFont]];
    
    [self.btnEditMessage setImage:[AMBValues imageFromBundleWithName:@"pencil" type:@"png" tintable:YES] forState:UIControlStateNormal];
    [[self.btnEditMessage imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnEditMessage setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.btnEditMessage.tintColor = [UIColor lightGrayColor];
    [self updateButton];
}

- (void)showOrHideSearchDoneButton {
    self.searchBarRightConstraint.constant = (self.searchBarRightConstraint.constant == 18) ? self.searchBarRightConstraint.constant + self.doneSearchingButton.frame.size.width + 18 : 18;
    [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    } completion:nil];
}

- (void)updateButton {
    self.sendButton.enabled = self.selected.count ? YES : NO;
    self.sendButton.backgroundColor = self.sendButton.enabled ? [[AMBThemeManager sharedInstance] colorForKey:ContactSendButtonBackgroundColor] : [UIColor lightGrayColor];
    
    switch (self.selected.count) {
        case 0:
            [self.sendButton setTitle:@"Select Contacts" forState:UIControlStateNormal];
            break;
        case 1:
            [self.sendButton setTitle:@"Send to 1 contact" forState:UIControlStateNormal];
            break;
        default:
            [self.sendButton setTitle:[NSString stringWithFormat:@"Send to %i contacts", (int)self.selected.count] forState:UIControlStateNormal];
            break;
    }
}

- (void)showHideFadeView {
    if (!self.fadeView) {
        self.fadeView = [[UIView alloc] initWithFrame:self.containerView.frame];
        self.fadeView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        self.fadeView.alpha = 0;
    }
    
    if ([self.fadeView isDescendantOfView:self.containerView]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.fadeView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.fadeView removeFromSuperview];
        }];
    } else {
        [self.containerView addSubview:self.fadeView];
        [self.containerView bringSubviewToFront:self.composeMessageView];
        [UIView animateWithDuration:0.3 animations:^{
            self.fadeView.alpha = 1;
        } completion:0];
    }
}


#pragma mark - IBActions

- (IBAction)sendButtonTapped:(id)sender {
    if (self.selected.count > 0 && ![self validateString:self.shortURL inString:self.composeMessageTextView.text]) {
        NSString *message = [NSString stringWithFormat:@"Please include your url in the message: %@", self.shortURL];
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:message withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
        return;
    } else if ([self.selected count] > 0 && [self validateString:self.shortURL inString:self.composeMessageTextView.text]) {
        switch (self.type) {
            case AMBSocialServiceTypeEmail:
                [self sendEmail];
                break;
            case AMBSocialServiceTypeSMS:
                [self sendSMS];
                break;
            default:
                break;
        }
    }
}

- (IBAction)clearAllButtonTapped:(id)sender {
    [self.selected removeAllObjects];
    [self refreshAllIncludingContacts:YES];
}

- (IBAction)doneSearchingButtonTapped:(id)sender {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.activeSearch = NO;
    [self showOrHideSearchDoneButton];
    [self.contactsTable reloadData];
}

- (IBAction)editMessageButtonTapped:(id)sender {
    if (!self.isEditing) {
        self.isEditing = YES;
        [self showHideFadeView];
        [self.composeMessageTextView becomeFirstResponder];
        self.composeMessageTextView.textColor = [UIColor blackColor];
        [self.btnEditMessage setImage:nil forState:UIControlStateNormal];
        [self.btnEditMessage setTitle:@"DONE" forState:UIControlStateNormal];
    } else {
        [self showHideFadeView];
        [self.composeMessageTextView resignFirstResponder];
        self.composeMessageTextView.textColor = [UIColor lightGrayColor];
        [self.btnEditMessage setImage:[AMBValues imageFromBundleWithName:@"pencil" type:@"png" tintable:YES] forState:UIControlStateNormal];
        [self.btnEditMessage setTitle:@"" forState:UIControlStateNormal];
        self.isEditing = NO;
    }
}


#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.contactsTable) {
        return (self.activeSearch) ? [self.filteredData count] : [self.data count];
    }
    
    return self.selected.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactsTable) {
        AMBContact *contact = self.activeSearch ? self.filteredData[indexPath.row] : self.data[indexPath.row];
        AMBContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        [cell setUpCellWithContact:contact isSelected:[self.selected containsObject:contact]];
        cell.delegate = self;
        
        return cell;
    } else {
        AMBContact *contact = [self.selected allObjects][indexPath.row];
        AMBSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedCell"];
        [cell setUpCellWithContact:contact];
        cell.delegate = self;
        
        return cell;
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
            [self refreshAllIncludingContacts:NO];
            return;
        }
        
        // If the contact is NOT SELECTED
        if ([self checkValidationForString:contact.value]) {
            [self.selected addObject:contact];
            [cell animateCheckmarkIn];
            [self refreshAllIncludingContacts:NO];
            return;
        }
        
        // If the contact is invalid
        [self showInvalidValueAlertForValue:contact.value];
    }
}


#pragma mark - SelectedCell Delegate

- (void)removeButtonTappedForContact:(AMBContact *)contact {
    [self.selected removeObject:contact];
    [self refreshAllIncludingContacts:YES];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showOrHideSearchDoneButton];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *fullSearchText =  [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.activeSearch = ([fullSearchText isEqualToString:@""]) ? NO : YES;
    [self searchWithText:fullSearchText];
    [self.contactsTable reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (!self.isEditing) { [self editMessageButtonTapped:nil]; }
    return YES;
}


#pragma mark - Keyboard Listener Functions

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)sender {
    keyboardShowing = YES;
    CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.isEditing) {
        self.bottomViewBottomConstraint.constant = keyboardFrame.size.height;
        self.composeBoxHeight.constant = self.composeMessageView.frame.size.height - self.sendButton.frame.size.height;
        self.sendButtonHeight.constant = 0;
        [self.view layoutIfNeeded];
        return;
    } else {
        self.contactTableBottomConstraint.constant = keyboardFrame.size.height - self.composeMessageView.frame.size.height;
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (!keyboardShowing) {
        return;
    }
    
    if (self.isEditing) {
        self.bottomViewBottomConstraint.constant = 0;
        self.composeBoxHeight.constant = self.composeMessageView.frame.size.height + originalSendButtonHeight;
        self.sendButtonHeight.constant = originalSendButtonHeight;
        [self.view layoutIfNeeded];
    } else {
        self.contactTableBottomConstraint.constant = 0;
    }
    
    keyboardShowing = NO;
}


#pragma mark - Send Functions

- (void)sendSMS {
    if (![self alreadyHaveNames]) {
        [self performSegueWithIdentifier:NAME_PROMPT_SEGUE_IDENTIFIER sender:self];
        return;
    }
    
    NSArray *validatedNumbers = [AMBBulkShareHelper validatedPhoneNumbers:[self.selected allObjects]];
    
    if (validatedNumbers.count > 0) {
        NSString *senderName = [NSString stringWithFormat:@"%@ %@", [AMBValues getUserFirstName], [AMBValues getUserLastName]];
        AMBBulkShareSMSObject *smsObject = [[AMBBulkShareSMSObject alloc] initWithPhoneNumbers:validatedNumbers fromSender:senderName message:self.composeMessageTextView.text];
        
        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:smsObject url:[AMBAmbassadorNetworkManager bulkShareSMSUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                DLog(@"Error for BulkShare SMS with Response Code - %li and Response - %@", (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
            } else {
                DLog(@"BulkShare SMS Success with Response Code - %li and Response - %@", (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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
            if (error) {
                DLog(@"Error for BulkShare Email with Response Code - %li and Response - %@", (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Unable to share message.  Please try again." withUniqueID:nil forViewController:self shouldDismissVCImmediately:NO];
            } else {
                DLog(@"BulkShare Email Success with Response Code - %li and Response - %@", (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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
    NSString *firstName = [AMBValues getUserFirstName];
    NSString *lastName = [AMBValues getUserLastName];
    
    return ([firstName isEqualToString:@""] || [lastName isEqualToString:@""]) ? NO : YES;
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
    switch (self.type) {
        case AMBSocialServiceTypeEmail:
            self.data = [NSMutableArray arrayWithArray:[AMBContactLoader sharedInstance].emailAddresses];
            break;
        case AMBSocialServiceTypeSMS:
            self.data = [NSMutableArray arrayWithArray:[AMBContactLoader sharedInstance].phoneNumbers];
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

- (BOOL)validateString:(NSString *)string inString:(NSString *)inString {
    return [inString rangeOfString:string].location != NSNotFound;
}

- (void)refreshAllIncludingContacts:(BOOL)refreshContactsTable {
    if (refreshContactsTable) { [self.contactsTable reloadData]; }
    [self.selectedTable reloadData];
    [self updateButton];
}

- (void)pullToRefresh {
    [[AMBContactLoader sharedInstance] forceReloadContacts];
    [self.selected removeAllObjects];
    [self updateButton];
    [self.refreshControl endRefreshing];
}


#pragma mark - Navigation

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    if ([segue.identifier isEqualToString:NAME_PROMPT_SEGUE_IDENTIFIER]) {
        AMBNamePrompt *vc = (AMBNamePrompt*)segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:CONTACT_CARD_SEGUE_IDENTIFIER]) {
        AMBContactCard *contactCardVC = (AMBContactCard*)segue.destinationViewController;
        contactCardVC.contact = self.selectedContact;
    }
}


#pragma mark - Share Track 

- (void)sendShareTrack:(NSArray *)contacts {
    AMBShareTrackNetworkObject *share = [[AMBShareTrackNetworkObject alloc] init];
    
    if (self.type == AMBSocialServiceTypeEmail) {
        share.recipient_email = [self valuesFromContacts:[self.selected allObjects]];
    } else if (self.type == AMBSocialServiceTypeSMS) {
        share.recipient_username = [self valuesFromContacts:[self.selected allObjects]];
    }
    
    share.short_code = self.urlNetworkObject.short_code;
    share.social_name = [AMBOptions serviceTypeStringValue:self.type];
    
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"Error for BulkShareTrack %@ with ResponseCode %li and Response %@", [AMBOptions serviceTypeStringValue:self.type], (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        } else {
            DLog(@"Successfully shared BulkShareTrack %@ with ResponseCode %li and Response %@", [AMBOptions serviceTypeStringValue:self.type], (long)((NSHTTPURLResponse*)response).statusCode, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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


#pragma mark - AMBNamePrompt Delegate 

- (void)namesUpdatedSuccessfully {
    [self sendSMS];
}


#pragma mark - AMBContactLoader Delegate

- (void)contactsFinishedLoadingSuccessfully {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[AMBUtilities sharedInstance] hideLoadingView];
        [self refreshContacts];
        [self.contactsTable reloadData];
    }];
}

- (void)contactsFailedToLoadWithError:(NSString *)errorTitle message:(NSString *)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        DLog(@"Error loading contacts - %@", message);
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"Sharing requires access to your contact book. You can enable this in your settings." withUniqueID:@"contactError" forViewController:self shouldDismissVCImmediately:NO];
        [AMBUtilities sharedInstance].delegate = self;
    }];
}


#pragma mark - AMBContactCell Delegate

- (void)longPressTriggeredForContact:(AMBContact *)contact {
    self.selectedContact = contact;
    [self performSegueWithIdentifier:CONTACT_CARD_SEGUE_IDENTIFIER sender:self];
}


#pragma mark - AMBUtitlites Delegate

- (void)okayButtonClickedForUniqueID:(NSString *)uniqueID {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
