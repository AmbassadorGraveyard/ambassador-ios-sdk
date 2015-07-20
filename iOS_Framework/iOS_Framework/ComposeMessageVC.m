//
//  ComposeMessageVC.m
//  iOS_Framework
//
//  Created by Diplomat on 7/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ComposeMessageVC.h"
#import "Constants.h"
#import "Utilities.h"



#pragma mark - Local Constants
UIColor* TOP_BORDER_COLOR()
{
    return ColorFromRGB(233, 233, 233);
}

UIEdgeInsets TEXT_BOX_INSETS()
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

float const TEXT_BOX_TOP_CONSTANT = 20.0;
float const TEXT_BOX_RIGHT_CONSTANT = -70.0;
float const TEXT_BOX_LEFT_CONSTANT = 10.0;
float const TEXT_BOX_BOTTOM_CONSTANT = -20.0;

float const EDIT_BUTTON_HEIGHT_CONSTANT = 16.0;
float const EDIT_BUTTON_WIDTH_CONSTANT = 40.0;
float const EDIT_BUTTON_RIGHT_CONSTANT = -15.0;
float const EDIT_BUTTON_TOP_CONSTANT = 20.0;

NSString * EDIT_BUTTON_IMAGE_NAME = @"pencil.png";
NSString * EDIT_BUTTON_SELECTED_TITLE = @"DONE";

UIColor * ACCENT_COLOR()
{
    return ColorFromRGB(60, 151, 211);
}
#pragma mark -



@interface ComposeMessageVC ()

@property UIView *composeMessageView;
@property UITextView *textBox;
@property UIView *topBorderView;

@end

@implementation ComposeMessageVC

- (id)initWithInitialMessage:(NSString *)string
{
    if ([super init])
    {
        self.defaultMessage = string;
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    DLog();
    
    self.view = [[UIView alloc] init];
    
    [self setUpSendButton];
    [self setUpTopBorder];
    [self setUpComposeMessageView];
    [self setUpTextBox];
    [self setUpEditButton];
    
    }

- (void)setUpSendButton
{
    DLog();
    
    // Initialize properties
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.titleLabel.font = DEFAULT_FONT();
    
    // Add to view hierarchy
    [self.view addSubview:self.sendButton];
    
    // Add autolayout constraints
    self.sendbuttonHeight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.0
                                                          constant:0.0];
    [self.view addConstraint:self.sendbuttonHeight]; 
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)setUpTopBorder
{
    DLog();
    
    // Initialize properties
    self.topBorderView = [[UIView alloc] init];
    self.topBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.topBorderView.backgroundColor = TOP_BORDER_COLOR();
    
    // Add to view hierarchy
    [self.view addSubview:self.topBorderView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:0.5]];
}

- (void)setUpComposeMessageView
{
    DLog();
    
    // Initialize properties
    self.composeMessageView = [[UIView alloc] init];
    self.composeMessageView.translatesAutoresizingMaskIntoConstraints = NO;
    //self.composeMessageView.backgroundColor = [UIColor whiteColor];
    
    // Add to view hierarchy
    [self.view addSubview:self.composeMessageView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.composeMessageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBorderView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.composeMessageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.composeMessageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)setUpTextBox
{
    DLog();
    
    // Initialize properties
    self.textBox = [[UITextView alloc] init];
    self.textBox.translatesAutoresizingMaskIntoConstraints = NO;
    //self.textBox.backgroundColor = [UIColor whiteColor];
    self.textBox.text = self.defaultMessage;
    self.textBox.font = DEFAULT_FONT();
    self.textBox.textColor = DEFAULT_GRAY_COLOR();
    self.textBox.editable = NO;
    self.textBox.textContainerInset = TEXT_BOX_INSETS();
    
    // Add to view hierarchy
    [self.composeMessageView addSubview:self.textBox];
    
    // Add autolayout constraints
    DLog(@"%f", TEXT_BOX_BOTTOM_CONSTANT);
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.textBox
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:TEXT_BOX_BOTTOM_CONSTANT]];
    DLog();
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.textBox
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:TEXT_BOX_RIGHT_CONSTANT]];
    DLog();
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.textBox
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:TEXT_BOX_LEFT_CONSTANT]];
    DLog();
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.textBox
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:TEXT_BOX_TOP_CONSTANT]];
}

- (void)setUpEditButton
{
    // Initialize properties
    self.editButton = [[UIButton alloc] init];
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.editButton setBackgroundImage:imageFromBundleNamed(EDIT_BUTTON_IMAGE_NAME) forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected];
    [self.editButton setTitle:EDIT_BUTTON_SELECTED_TITLE forState:UIControlStateSelected];
    self.editButton.titleLabel.font = DEFAULT_FONT_SMALL();
    [self.editButton setTitleColor:ACCENT_COLOR() forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view hierarchy
    [self.composeMessageView addSubview:self.editButton];
    
    // Add autolayout constraints
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.0
                                                                         constant:EDIT_BUTTON_HEIGHT_CONSTANT]];
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:0.0
                                                                         constant:EDIT_BUTTON_WIDTH_CONSTANT]];
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:EDIT_BUTTON_RIGHT_CONSTANT]];
    [self.composeMessageView addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.composeMessageView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:EDIT_BUTTON_TOP_CONSTANT]];
}

- (void)updateButtonWithCount:(NSUInteger)count
{
    self.sendButton.backgroundColor = count == 0 ? DEFAULT_GRAY_COLOR() : ACCENT_COLOR();
    NSString *text = @"Select contacts";
    
    if (count >= 1)
    {
        text = [NSString stringWithFormat:@"Send to %ld contact", (unsigned long)count];
        if (count > 1)
        {
            text = [text stringByAppendingString:@"s"];
        }
    }
    
    [self.sendButton setTitle:text forState:UIControlStateNormal];
}

- (void)editButtonPressed:(UIButton *)button
{
    DLog();
    self.editButton.selected = !self.editButton.selected;
    
    
    if (self.editButton.selected)
    {
        self.textBox.editable = YES;
        self.textBox.textColor = [UIColor blackColor];
        [self.textBox becomeFirstResponder];
        
    }
    else
    {
        self.textBox.editable = NO;
        self.textBox.textColor = DEFAULT_GRAY_COLOR();
        [self.textBox resignFirstResponder];
    }
}

@end
