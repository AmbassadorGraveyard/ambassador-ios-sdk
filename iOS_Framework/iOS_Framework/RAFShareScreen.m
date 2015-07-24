//
//  RAFShareScreen.m
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "RAFShareScreen.h"
#import "Constants.h"
#import "ShareServiceCell.h"
#import <Social/Social.h>
#import "LinkedInShareViewController.h"
#import "LinkedInAuthorizeWebView.h"
#import "ContactLoader.h"
#import "Utilities.h"
#import "ContactSelectionViewController.h"



#pragma mark - Local Constants
NSString * const SERVICE_TITLE_KEY = @"title";
NSString * const SERVICE_LOGO_KEY = @"logo";
NSString * const SERVICE_BACKGROUND_COLOR_KEY = @"backgroundColor";
NSString * const SERVICE_BORDER_COLOR_KEY = @"borderColor";

NSString * const FACEBOOK_TITLE = @"Facebook";

NSString * const TWITTER_TITLE = @"Twitter";

NSString * const LINKEDIN_TITLE = @"LinkedIn";

NSString * const SMS_TITLE = @"SMS";

NSString * const EMAIL_TITLE = @"Email";

float const TITLE_LABLE_HEIGHT = 30.0;
float const TITLE_LABEL_TOP_PADDING_MULTIPLIER = 0.07;
NSString * const TITLE_LABEL_TEXT = @"Spread the word";

float const DESCRIPTION_LABLE_HEIGHT = 30.0;
NSString * const DESCRIPTION_LABLE_TEXT = @"Refer a friend and recieve a free gift";

float const SHORT_CODE_FIELD_HEIGHT = 35.0;
float const SHORT_CODE_FIELD_WIDTH_MULTIPLIER = 0.9;
float const SHORT_CODE_FIELD_TOP_PADDING = 40.0;
NSString * const SHORT_CODE_CLIPBOARD_IMAGE_NAME = @"clipboard.png";

float const SHARE_SERVICE_TOP_PADDING = 60.0;
float const SHARE_SERVICE_WIDTH_MULTIPLIER = 0.9;

NSString * const AMB_SHARE_TRACK_URL = @"https://dev-ambassador-api.herokuapp.com/track/share/";
NSString * const SHARE_TRACK_SHORT_CODE_KEY = @"short_code";
NSString * const SHARE_TRACK_RECIPIENT_EMAIL_KEY = @"recipient_email";
NSString * const SHARE_TRACK_SOCIAL_NAME_KEY = @"social_name";
NSString * const SHARE_TRACK_RECIPIENT_USERNAME_KEY = @"recipient_username";

NSString * CELL_IDENTIFIER = @"cellIdentifier";
CGSize CELL_SIZE()
{
    return CGSizeMake(80.0, 115.0);
}

CGRect SHORT_CODE_PADDING_FRAME()
{
    return CGRectMake(0, 0, 8, 30);
}

CGRect SHORT_CODE_CLIPBOARD_FRAME()
{
    return CGRectMake(0, 0, 27, 17);
}
#pragma mark -



@interface RAFShareScreen () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, LinkedInAuthorizeWebViewDelegate, ContactLoaderDelegate, LinkedInShareDelegate>

@property UILabel *titleLabel;
@property UILabel *descriptionLabel;
@property UITextField *shortCodeField;
@property UIView *lowerBorder;
@property UICollectionView *shareServices;
@property UICollectionViewFlowLayout *flowLayout;
@property NSMutableArray *shareServiceInformation;
@property UIButton *clipboardButton;
@property ContactLoader *loader;
@property LinkedInShareViewController *lkdIn;
@property NSString *shortURL;
@property NSString *shortCode;

@end



@implementation RAFShareScreen

#pragma mark - Initialization / Lifecycle
- (id)initWithShortURL:(NSString *)url shortCode:(NSString *)shortCode
{
    DLog();
    if ([super init])
    {
        self.shortURL = [NSString stringWithString:url];
        self.shortCode = [NSString stringWithString:shortCode];
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    DLog();
    

    
    
    // Fill the service information array for service cells to use
    self.shareServiceInformation = [[NSMutableArray alloc] init];
    [self addServiceWithTitle:FACEBOOK_TITLE logoName:FB_IMAGE_NAME backgroundColor:FACEBOOK_COLOR() borderColor:CLEAR_COLOR()];
    [self addServiceWithTitle:TWITTER_TITLE logoName:TWTR_IMAGE_NAME backgroundColor:TWITTER_COLOR() borderColor:CLEAR_COLOR()];
    [self addServiceWithTitle:LINKEDIN_TITLE logoName:LKDN_IMAGE_NAME backgroundColor:LINKEDIN_COLOR() borderColor:CLEAR_COLOR()];
    [self addServiceWithTitle:SMS_TITLE logoName:SMS_IMAGE_NAME backgroundColor:CLEAR_COLOR() borderColor:DEFAULT_GRAY_COLOR()];
    [self addServiceWithTitle:EMAIL_TITLE logoName:EMAIL_IMAGE_NAME backgroundColor:CLEAR_COLOR() borderColor:DEFAULT_GRAY_COLOR()];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *closeButton = [[UIButton alloc] initWithFrame:AMB_CLOSE_BUTTON_FRAME()];
    [closeButton setImage:imageFromBundleNamed(AMB_CLOSE_BUTTON_NAME) forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    // Set main view properties
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self titleLableSetUp];
    [self descriptionLabelSetUp];
    [self shortCodeFieldSetUp];
    [self lowerBorderSetUp];
    [self shareServiceSetUp];
}

- (void)addServiceWithTitle:(NSString *)title logoName:(NSString *)logoName backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor
{
    DLog(@"%@", title);
    NSDictionary *service = @{ SERVICE_TITLE_KEY : title, SERVICE_LOGO_KEY : imageFromBundleNamed(logoName),
                               SERVICE_BACKGROUND_COLOR_KEY : backgroundColor, SERVICE_BORDER_COLOR_KEY : borderColor };
    [self.shareServiceInformation addObject:service];
}

- (void)titleLableSetUp
{
    DLog();
    
    // Initialize properties
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = DEFAULT_FONT();
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // Add to view hierarchy
    [self.view addSubview:self.titleLabel];
    
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleLabel
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:TITLE_LABLE_HEIGHT]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleLabel
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleLabel
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:TITLE_LABEL_TOP_PADDING_MULTIPLIER
                              constant:0.0]];
}

- (void)descriptionLabelSetUp
{
    DLog();
    
    // Initialize properties
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.font = DEFAULT_FONT();
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = DEFAULT_GRAY_COLOR();
    
    // Add to view hierarchy
    [self.view addSubview:self.descriptionLabel];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionLabel
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:DESCRIPTION_LABLE_HEIGHT]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionLabel
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionLabel
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.titleLabel
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:0.0]];
}

- (void)shortCodeFieldSetUp
{
    DLog();
    
    // Initialize properties
    self.shortCodeField = [[UITextField alloc] init];
    self.shortCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    self.shortCodeField.font = DEFAULT_FONT();
    self.shortCodeField.textColor = DEFAULT_GRAY_COLOR();
    self.shortCodeField.text = self.shortURL;
    self.shortCodeField.backgroundColor = DEFAULT_LIGHT_GRAY_COLOR();
    self.shortCodeField.delegate = self;
    // Left padding view
    UIView *paddingView = [[UIView alloc] initWithFrame:SHORT_CODE_PADDING_FRAME()];
    self.shortCodeField.leftView = paddingView;
    self.shortCodeField.leftViewMode = UITextFieldViewModeAlways;
    // Right clipboard view
    UIButton *clipboardButton = [[UIButton alloc] initWithFrame:SHORT_CODE_CLIPBOARD_FRAME()];
    [clipboardButton setImage:imageFromBundleNamed(SHORT_CODE_CLIPBOARD_IMAGE_NAME) forState:UIControlStateNormal];
    [clipboardButton addTarget:self action:@selector(clipboardButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    self.shortCodeField.rightView = clipboardButton;
    self.shortCodeField.rightViewMode = UITextFieldViewModeAlways;
    
    // Add to view hierarchy
    [self.view addSubview:self.shortCodeField];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shortCodeField
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:SHORT_CODE_FIELD_HEIGHT]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shortCodeField
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:SHORT_CODE_FIELD_WIDTH_MULTIPLIER
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shortCodeField
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shortCodeField
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.descriptionLabel
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:SHORT_CODE_FIELD_TOP_PADDING]];
}

- (void)lowerBorderSetUp
{
    DLog();
    
    // Initialize properties
    self.lowerBorder = [[UIView alloc] init];
    self.lowerBorder.translatesAutoresizingMaskIntoConstraints = NO;
    self.lowerBorder.backgroundColor = [UIColor blackColor];
    
    // Add to view hierarchy
    [self.view addSubview:self.lowerBorder];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.lowerBorder
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:1.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.lowerBorder
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:SHORT_CODE_FIELD_WIDTH_MULTIPLIER
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.lowerBorder
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.lowerBorder
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.shortCodeField
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:0.0]];
}

- (void)shareServiceSetUp
{
    DLog();
    
    // Initialize flowlaout for the collection view
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0.0;
    
    // Initialize properties
    self.shareServices = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.flowLayout];
    self.shareServices.translatesAutoresizingMaskIntoConstraints = NO;
    self.shareServices.delegate = self;
    self.shareServices.dataSource = self;
    [self.shareServices registerClass:[ShareServiceCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    self.shareServices.backgroundColor = CLEAR_COLOR();
    
    // Add to view hierarchy
    [self.view addSubview:self.shareServices];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shareServices
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.lowerBorder
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:SHARE_SERVICE_TOP_PADDING]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shareServices
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:SHARE_SERVICE_WIDTH_MULTIPLIER
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shareServices
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.shareServices
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:0.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"%@", self.rafParameters);
    self.titleLabel.text = self.rafParameters.welcomeTitle;
    self.descriptionLabel.text = self.rafParameters.welcomeDescription;
    self.navigationItem.title = self.rafParameters.navBarTitle;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Prefetch the contacts in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        DLog(@"Loading Contacts");
        self.loader = [[ContactLoader alloc] initWithDelegate:self];
    });
}



#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    DLog(@"%ld", (long)self.shareServiceInformation.count);
    
    return self.shareServiceInformation.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.logoBackground.backgroundColor = self.shareServiceInformation[indexPath.row][SERVICE_BACKGROUND_COLOR_KEY];

    UIColor *borderColor = self.shareServiceInformation[indexPath.row][SERVICE_BORDER_COLOR_KEY];
    cell.logoBackground.layer.borderColor = borderColor.CGColor;

    cell.logo.image = self.shareServiceInformation[indexPath.row][SERVICE_LOGO_KEY];
    
    cell.title.text = self.shareServiceInformation[indexPath.row][SERVICE_TITLE_KEY];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{ return CELL_SIZE(); }



#pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *serviceTitle = self.shareServiceInformation[indexPath.row][SERVICE_TITLE_KEY];
    SLComposeViewController *vc = nil;
    DLog(@"Press on %@", serviceTitle);
    
    NSString *message = [NSString stringWithFormat:@"%@ %@", self.rafParameters.defaultShareMessage, self.shortCodeField.text];
    
    if ([serviceTitle isEqualToString:FACEBOOK_TITLE])
    {
        vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"facebook" recipientUsername:@""];
            }
        };
    }
    else if ([serviceTitle isEqualToString:TWITTER_TITLE])
    {
        vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"twitter" recipientUsername:@""];
            }
        };
    }
    else if ([serviceTitle isEqualToString:LINKEDIN_TITLE])
    {
        LinkedInShareViewController* lkdIn = [[LinkedInShareViewController alloc] initWithDefaultMessage:message];
        lkdIn.delegate = self;
        
        if (![lkdIn isAuthorized])
        {
            LinkedInAuthorizeWebView *authVC = [[LinkedInAuthorizeWebView alloc] init];
            authVC.delegate = self;
            [self.navigationController pushViewController:authVC animated:YES];
        }
        else
        {
            [self presentCrossDisolved:lkdIn];
        }
    }
    else if ([serviceTitle isEqualToString:EMAIL_TITLE])
    {
        ContactSelectionViewController *contactVC = [[ContactSelectionViewController alloc] initWithInitialMessage:message];
        contactVC.navigationItem.title = self.rafParameters.navBarTitle;
        contactVC.data = self.loader.emailAddresses;
        [self.navigationController pushViewController:contactVC animated:YES];
    }
    else if ([serviceTitle isEqualToString:SMS_TITLE])
    {
        ContactSelectionViewController *contactVC = [[ContactSelectionViewController alloc] initWithInitialMessage:message];
        contactVC.navigationItem.title = self.rafParameters.navBarTitle;
        contactVC.data = self.loader.phoneNumbers;
        [self.navigationController pushViewController:contactVC animated:YES];
    }
    
    if (vc)
    {
        [vc setInitialText:message];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}



#pragma mark - TextField Activity Functions
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return NO; }

- (void)clipboardButtonPress:(UIButton *)button
{
    DLog();
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.shortCodeField.text];
}



#pragma mark - Close function
- (void)closeButtonPressed:(UIButton *)button
{
    DLog();
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - LinkedInAuthorizeWebViewDelegate
- (void)userDidContinue
{
    DLog();
    [self.navigationController popViewControllerAnimated:YES];
    NSString *message = [NSString stringWithFormat:@"%@ %@", self.rafParameters.defaultShareMessage, self.shortCodeField.text];
    LinkedInShareViewController* lkdIn = [[LinkedInShareViewController alloc] initWithDefaultMessage:message];
    lkdIn.delegate = self;
    [self presentCrossDisolved:lkdIn];
}




#pragma mark - LinkedInShareDelegate
- (void)userDidPost:(NSMutableDictionary *)data
{
    DLog(@"%@", data);
    [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"linkedin" recipientUsername:@""];
}

- (void)userMustReauthenticate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authentication Error" message:@"Sorry. You're currently logged out. Please log in and try your post again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue to login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   DLog();
                                       LinkedInAuthorizeWebView *authVC = [[LinkedInAuthorizeWebView alloc] init];
                                       authVC.delegate = self;
                                   [self.navigationController pushViewController:authVC animated:YES];
                               }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];

    }


#pragma mark - ContactLoaderDelegate
- (void)contactsFailedToLoadWithError:(NSString *)errorTitle message:(NSString *)message
{
    DLog();
    [self simpleAlertWith:errorTitle message:message];
}



#pragma mark - 
- (void)presentCrossDisolved:(UIViewController *)vc
{
    DLog();
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated: YES completion:nil];
}



#pragma mark - Helper Functions
- (void)simpleAlertWith:(NSString*)title message:(NSString *)message
{
    DLog();
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   DLog();
                                   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - Share track
- (void)postShareTrackWithShortCode:(NSString *)shortCode recipientEmail:(NSString *)recipientEmail socialName:(NSString *)socialName recipientUsername:(NSString *)recipientUsername
{
    DLog();
    //Create payload
    NSDictionary *payload = @{ SHARE_TRACK_SHORT_CODE_KEY : shortCode,
                               SHARE_TRACK_RECIPIENT_EMAIL_KEY : recipientEmail,
                               SHARE_TRACK_SOCIAL_NAME_KEY : socialName,
                               SHARE_TRACK_RECIPIENT_USERNAME_KEY : recipientUsername };
    
    NSURL *url = [NSURL URLWithString:AMB_SHARE_TRACK_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:AMB_AUTHORIZATION_TOKEN forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              DLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  // Looking for a "Polling" response
                  DLog(@"Response from backend from sending identify: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
              }
          }
          else
          {
              DLog(@"Error: %@", error.localizedDescription);
          }
      }];
    [task resume];
}

@end
