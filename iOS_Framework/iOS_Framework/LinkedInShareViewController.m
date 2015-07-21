//
//  LinkedInShareViewController.m
//  iOS_Framework
//
//  Created by Diplomat on 7/17/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "LinkedInShareViewController.h"
#import "Utilities.h"
#import "Constants.h"



#pragma mark - Local Constants
typedef struct
{
    float widthConstant;
    float widthMultiplier;
    float topOffsetMultiplier;
    float heightConstant;
} ContentViewConstraints;

ContentViewConstraints getContentViewConstraints()
{
    ContentViewConstraints viewConstraints;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        viewConstraints.widthMultiplier = 0.0;
        viewConstraints.widthConstant = 390.0;
        viewConstraints.topOffsetMultiplier = 0.30;
        viewConstraints.heightConstant = 150.0;
    }
    else
    {
        viewConstraints.widthMultiplier = 1.0;
        viewConstraints.widthConstant = -30.0;
        viewConstraints.topOffsetMultiplier = 0.14;
        viewConstraints.heightConstant = 150.0;
    }
    
    return viewConstraints;
}

float CONTENT_VIEW_CORNER_RADIUS = 5.0;

UIColor* BACKGROUND_COLOR()
{
    return [UIColor colorWithWhite:1.0 alpha:0.97];
}

UIFont* NAV_BAR_FONT()
{
    return [UIFont boldSystemFontOfSize:18.0];
}

UIEdgeInsets MESSAGE_BOX_INSETS()
{
    return UIEdgeInsetsMake(10, 7, 10, 7);
}

UIColor * LOWER_BORDER_COLOR()
{
    return [UIColor colorWithWhite:0.0 alpha:0.2];
}

NSString * const NAV_BAR_TITLE = @"LinkedIn";
NSString * const NAV_BAR_POST_BUTTON_TITLE = @"Post";
NSString * const NAV_BAR_CANCEL_BUTTON_TITLE = @"Cancel";

float NAV_BAR_HEIGHT = 45.0;

NSString * const LINKEDIN_SHARE_URL = @"https://api.linkedin.com/v1/people/~/shares?format=json";
NSString * const SHARE_COMMENT_KEY = @"comment";
NSString * const SHARE_VISIBILITY_KEY = @"visibility";
NSString * const SHARE_CODE_KEY = @"code";
#pragma mark - 



@interface LinkedInShareViewController ()

@property UIView *contentView;
@property UINavigationBar *navBar;
@property UITextView *messageBox;
@property NSString *clientCode;
@property UIView *lowerBorder;
@property NSString *defaultMessage;
@property BOOL blurViewAdded;

@end



@implementation LinkedInShareViewController

#pragma mark - Initialization
- (id)initWithDefaultMessage:(NSString *)message
{
    if ([super init])
    {
        DLog();
        self.defaultMessage = message;
        [self setUp];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    if (!self.blurViewAdded) {
        DLog();
        // Adding blurview behind contentView
        UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        blurView.layer.cornerRadius = CONTENT_VIEW_CORNER_RADIUS;
        blurView.clipsToBounds = YES;
        [self.contentView addSubview:blurView];
        [self.contentView sendSubviewToBack:blurView];
        self.blurViewAdded = YES;
    }
}

- (void) setUp
{
    DLog();
    
    [self isAuthorized];
    
    self.view.backgroundColor = DEFAULT_FADE_VIEW_COLOR(true);
    
    [self setUpContentView];
    [self setUpNavBar];
    [self setUpLowerBorder];
    [self setUpMessageBox];
}

- (BOOL)isAuthorized
{
    DLog();
    NSDictionary *token = [[NSUserDefaults  standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
    DLog(@"%@", token);
    if (token) {
        NSDate *referenceDate = token[LINKEDIN_EXPIRES_KEY];
        if (!([referenceDate timeIntervalSinceNow] < 0.0))
        {
            DLog();
            return YES;
        }
    }
    return NO;
}

- (void)setUpContentView
{
    DLog();
    
    // Initialize properties
    ContentViewConstraints viewConstraints = getContentViewConstraints();
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = BACKGROUND_COLOR();
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.layer.cornerRadius = CONTENT_VIEW_CORNER_RADIUS;
    
    // Add to view heierarchy
    [self.view addSubview:self.contentView];
    
    // Add autolayout constraints
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.contentView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:viewConstraints.heightConstant]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.contentView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:viewConstraints.widthMultiplier
                              constant:viewConstraints.widthConstant]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.contentView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.contentView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:viewConstraints.topOffsetMultiplier
                              constant:0.0]];
}

- (void)setUpNavBar
{
    DLog();
    
    // Initialize properties
    self.navBar = [[UINavigationBar alloc] init];
    // Nav bar title
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = NAV_BAR_TITLE;
    [UINavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName : NAV_BAR_FONT() };
    // Nav bar "cancel" button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NAV_BAR_CANCEL_BUTTON_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    [leftBarButton setTitleTextAttributes:@{ NSFontAttributeName : DEFAULT_FONT_LARGE() }forState:UIControlStateNormal];
    navItem.leftBarButtonItem = leftBarButton;
    // Nav bar "post" button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NAV_BAR_POST_BUTTON_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(postButtonPressed:)];
    [rightBarButton setTitleTextAttributes:@{ NSFontAttributeName : NAV_BAR_FONT() } forState:UIControlStateNormal];
    navItem.rightBarButtonItem = rightBarButton;
    self.navBar.items = @[ navItem ];
    self.navBar.layer.cornerRadius = CONTENT_VIEW_CORNER_RADIUS;
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.navBar.clipsToBounds = YES;
            //self.navBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.70];
    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add to view hierarchy
    [self.contentView addSubview:self.navBar];
    
    // Add autolayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.navBar
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.0
                                     constant:NAV_BAR_HEIGHT]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.navBar
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.navBar
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.navBar
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:0.0]];
}

- (void)setUpMessageBox
{
    DLog();
    
    // Initialize properties
    self.messageBox = [[UITextView alloc] init];
    self.messageBox.text = self.defaultMessage;
    self.messageBox.font = [UIFont systemFontOfSize:18];
    self.messageBox.backgroundColor = CLEAR_COLOR();
    self.messageBox.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageBox.textContainerInset = MESSAGE_BOX_INSETS();
    self.messageBox.layer.cornerRadius = CONTENT_VIEW_CORNER_RADIUS;
    
    // Add to view hierarchy
    [self.contentView addSubview:self.messageBox];
    
    // Add autolayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.messageBox
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.messageBox
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.messageBox
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.messageBox
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.lowerBorder
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0
                                     constant:0.0]];
    
    // Bring up keyboard
    [self.messageBox becomeFirstResponder];
}

- (void)setUpLowerBorder
{
    DLog();
    
    // Initialize properties
    self.lowerBorder = [[UIView alloc] init];
    self.lowerBorder.translatesAutoresizingMaskIntoConstraints = NO;
    self.lowerBorder.backgroundColor = LOWER_BORDER_COLOR();
    
    // Add to view hierarchy
    [self.contentView addSubview:self.lowerBorder];
    
    // Add autolayout constraints
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.lowerBorder
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.0
                                     constant:0.5]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.lowerBorder
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.lowerBorder
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.lowerBorder
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.navBar
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0
                                     constant:0.0]];
}



#pragma mark - Navigation
- (void)postButtonPressed:(UIButton *)button
{
    DLog();
    
    [self share];
    [self.messageBox resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonPressed:(UIButton *)button
{
    DLog();
    
    [self.messageBox resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - LinkedIn API
- (void)share
{
    DLog();
    
    NSDictionary *authKey = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];

    NSURL *url = [NSURL URLWithString:LINKEDIN_SHARE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authKey[LINKEDIN_ACCESS_TOKEN_KEY]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    NSDictionary *payload = @{ SHARE_COMMENT_KEY : self.messageBox.text, SHARE_VISIBILITY_KEY : @{ SHARE_CODE_KEY : @"connections-only" } };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        DLog();
          if (!error)
          {
              DLog(@"Network request response code - %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  [self.delegate userDidPost:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                  //TODO: call completion handler
              }
              else if (((NSHTTPURLResponse *)response).statusCode == 400)
              {
                  [self simpleAlertWith:@"Posting Error" message:@"You may have already posted this comment"];
              }
              else
              {
                  [self simpleAlertWith:@"Posting Error" message:@"Your post couldn't be completed due to a network error"];
              }
          }
          else
          {
              DLog(@"Error: %@", error.localizedDescription);
              [self simpleAlertWith:@"Network Error" message:@"Your post couldn't be completed due to a network error"];
          }
    }];
    [task resume];
}



#pragma mark - Helper Functions
- (void)simpleAlertWith:(NSString*)title message:(NSString *)message
{
    DLog();
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alert addAction:okAction];
    
    [self.presentingViewController presentViewController:alert animated:YES completion:nil];
}

@end
