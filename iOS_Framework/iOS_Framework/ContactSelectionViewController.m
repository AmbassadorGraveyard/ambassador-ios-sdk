//
//  ContactSelectionViewController.m
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ContactSelectionViewController.h"
#import "SelectedTableVC.h"
#import "ContactsTableVC.h"
#import "Constants.h"
#import "ComposeMessageVC.h"
#import "Utilities.h"

typedef struct {
    float contactsTableWidthMultiplier;
    float selectionTableWidthMultiplier;
    BOOL selectionTableHidden;
} SubViewConstraints;

SubViewConstraints getConstraints()
{
    SubViewConstraints constraints;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        constraints.contactsTableWidthMultiplier = 0.5;
        constraints.selectionTableWidthMultiplier = 0.5;
        constraints.selectionTableHidden = NO;
    }
    else
    {
        constraints.contactsTableWidthMultiplier = 1.0;
        constraints.selectionTableWidthMultiplier = 0.0;
        constraints.selectionTableHidden = YES;
    }
    
    return constraints;
}

float const SEND_BUTTON_HEIGHT = 42.0;
float const COMPOSE_MESSAGE_BOX_HEIGHT = 123.0;

@interface ContactSelectionViewController () <SelectedContactsProtocol>

@property UIView *flexView;
@property UIView *fadeInView;
@property ContactsTableVC *contactsTable;
@property SelectedTableVC *selectionTable;
@property ComposeMessageVC *composeBox;
@property NSMutableSet *selected;
// Allow for dynamic resizing
@property NSLayoutConstraint *flexViewBottom;
@property NSLayoutConstraint *composeBoxHeight;
@property NSLayoutConstraint *composeBoxWidth;
@property NSLayoutConstraint *composeBoxBottom;

@end

@implementation ContactSelectionViewController

- (id)initWithInitialMessage:(NSString *)string
{
    if ([super init])
    {
        self.defaultMessage = string;
    }
    return self;
}

- (void)viewDidLoad {
    DLog();
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp
{
    DLog();
    
    // Navigation bar set up
    self.navigationItem.title = AMB_RAF_SHARE_SERVICES_TITLE;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:AMB_CLOSE_BUTTON_FRAME()];
    [closeButton setImage:imageFromBundleNamed(AMB_BACK_BUTTON_NAME) forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;

    // Start reicieving keyboard notifications
    [self registerForKeyboardNotifications];
    
    // Initialize the selected set
    self.selected = [[NSMutableSet alloc] init];
    
    // Set background and initialize the left and right views
    // This needs to be done early here because we might have to hide the
    // right view if we are on a phone.
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectionTable = [[SelectedTableVC alloc] init];
    self.contactsTable = [[ContactsTableVC alloc] init];
    
    [self setUpFlexView];
    [self setUpComposeMessageBox];
    [self setUpContactsTable];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self setUpSelectedTable];
    }
    
    [self setUpFadeInView];
}

// TODO: unregister when dealloc

- (void)setUpFlexView
{
    // Initialize properties
    self.flexView = [[UIView alloc] init];
    self.flexView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add to view hierarchy
    [self.view addSubview:self.flexView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flexView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flexView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flexView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0.0]];
    self.flexViewBottom = [NSLayoutConstraint constraintWithItem:self.flexView
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.view
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0.0];
    [self.view addConstraint: self.flexViewBottom];
}

- (void)setUpComposeMessageBox
{
    // Initialize properties and add controller to container's children
    SubViewConstraints constraints = getConstraints();
    self.composeBox = [[ComposeMessageVC alloc] initWithInitialMessage:self.defaultMessage];
    [self addChildViewController:self.contactsTable];
    self.composeBox.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.composeBox.sendbuttonHeight.constant = SEND_BUTTON_HEIGHT;
    
    // Refresh the button UI properties
    [self.composeBox updateButtonWithCount:self.selected.count];
    
    // Add to view hierarchy
    [self.flexView addSubview:self.composeBox.view];
    
    // Add autolayout constraints
    self.composeBoxHeight = [NSLayoutConstraint constraintWithItem:self.composeBox.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.flexView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.0
                                                          constant:COMPOSE_MESSAGE_BOX_HEIGHT];
    [self.flexView addConstraint:self.composeBoxHeight];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.composeBox.view
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    self.composeBoxWidth = [NSLayoutConstraint constraintWithItem:self.composeBox.view
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.flexView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:constraints.contactsTableWidthMultiplier
                                                         constant:0.0];
    [self.flexView addConstraint:self.composeBoxWidth];
    self.composeBoxBottom = [NSLayoutConstraint constraintWithItem:self.composeBox.view
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.flexView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0];
    [self.flexView addConstraint:self.composeBoxBottom];
}

- (void)setUpContactsTable
{
    // Initialize properties and add controller to container's children
    SubViewConstraints constraints = getConstraints();
    self.contactsTable.data = self.data;
    self.contactsTable.delegate = self;
    self.contactsTable.selected = self.selected;
    [self addChildViewController:self.contactsTable];
    
    // Add view to the hierarchy
    [self.flexView addSubview:self.contactsTable.view];
    
    // Add autolayout constraints
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsTable.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsTable.view
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsTable.view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:constraints.contactsTableWidthMultiplier
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsTable.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.composeBox.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
}

- (void)setUpSelectedTable
{
    // Initialize properties and add controller to container's children
    SubViewConstraints constraints = getConstraints();
    self.selectionTable.delegate = self;
    [self addChildViewController:self.selectionTable];
    self.selectionTable.selected = self.selected;
    [self.flexView addSubview:self.selectionTable.view];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionTable.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionTable.view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:constraints.selectionTableWidthMultiplier
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionTable.view
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionTable.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.composeBox.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
}

- (void)setUpFadeInView
{
    // Initialize properties
    self.fadeInView = [[UIView alloc] init];
    self.fadeInView.translatesAutoresizingMaskIntoConstraints = NO;
    self.fadeInView.backgroundColor = DEFAULT_FADE_VIEW_COLOR(false);
    self.fadeInView.hidden = YES;
    [self.flexView addSubview:self.fadeInView];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.fadeInView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.fadeInView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.fadeInView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.flexView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    [self.flexView addConstraint:[NSLayoutConstraint constraintWithItem:self.fadeInView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.composeBox.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
}

#pragma mark - TableViewProtocols
- (void)selectedContactsChanged
{
    DLog();
    [self.composeBox updateButtonWithCount:self.selected.count];
    [self.contactsTable.tableView reloadData];
    self.selectionTable.data = [NSMutableArray arrayWithArray:[self.selected allObjects]];
    [self.selectionTable.tableView reloadData];
}



#pragma mark - Keyboard Adjustments
- (void)registerForKeyboardNotifications
{
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
    if (self.composeBox.editButton.selected)
    {
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        [self.view layoutIfNeeded];
        
        self.flexViewBottom.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.composeBoxWidth.constant = [UIScreen mainScreen].bounds.size.width / 2;
        }
        [self.view bringSubviewToFront:self.composeBox.view];
        self.composeBoxHeight.constant = COMPOSE_MESSAGE_BOX_HEIGHT - SEND_BUTTON_HEIGHT;
        //self.composeBoxBottom.constant = 0;
        self.fadeInView.hidden = NO;
    }
    
    self.composeBox.sendbuttonHeight.constant = 0;
    NSTimeInterval duration = 0.0;
    float oldConstant = self.flexViewBottom.constant;
    
    //Only animate slide slowly if full keyboard is appearing vs the sugguestion bar appearing
    duration = (ABS(self.flexViewBottom.constant - oldConstant) < 100) ? 0.1 : 1.5;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    DLog();
    self.flexViewBottom.constant = 0;
    self.composeBox.sendbuttonHeight.constant = SEND_BUTTON_HEIGHT;
    self.composeBoxHeight.constant = COMPOSE_MESSAGE_BOX_HEIGHT;
    //self.composeBoxBottom.constant -= SEND_BUTTON_HEIGHT;
    self.composeBoxWidth.constant = 0;
    self.fadeInView.hidden = YES;
    [self.view layoutIfNeeded];
}

- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
