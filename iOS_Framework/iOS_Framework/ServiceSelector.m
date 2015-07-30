//
//  ServiceSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "ServiceSelector.h"
#import "ShareServiceCell.h"
#import "ShareService.h"
#import "ShareServicesConstants.h"
#import "ContactSelector.h"
#import "ContactLoader.h"
#import "AuthorizeLinkedIn.h"
#import "Utilities.h"
#import "LinkedInAPIConstants.h"
#import "Constants.h"
#import <Social/Social.h>
#import "LinkedInShare.h"
#import "ShareTrack.h"


@interface ServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate,
                               ContactLoaderDelegate, LinkedInAuthorizeDelegate,
                               ShareServiceDelegate, ContactSelectorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) ContactLoader *loader;

@end

@implementation ServiceSelector

#pragma mark -
NSString * const CELL_IDENTIFIER = @"serviceCell";
NSString * const CONTACT_SELECTOR_SEGUE = @"goToContactSelector";
NSString * const LKND_AUTHORIZE_SEGUE = @"goToAuthorizeLinkedIn";
float const CELL_BORDER_WIDTH = 2.0;
float const CELL_CORNER_RADIUS = CELL_BORDER_WIDTH;



#pragma mark - Initialization
- (id)initWithPreferences:(ServiceSelectorPreferences *)prefs
{
    if ([super init])
    {
        self.prefs = prefs;
    }
    
    return self;
}

- (void)addServices
{
    if (!self.services) { self.services = [[NSMutableArray alloc] init]; }
    
    [self addServiceWithTitle:FACEBOOK_TITLE
                     logoName:FACEBOOK_LOGO_IMAGE
              backgroundColor:FACEBOOK_BACKGROUND_COLOR()
                  borderColor:FACEBOOK_BORDER_COLOR()];
    [self addServiceWithTitle:TWITTER_TITLE
                     logoName:TWITTER_LOGO_IMAGE
              backgroundColor:TWITTER_BACKGROUND_COLOR()
                  borderColor:TWITTER_BORDER_COLOR()];
    [self addServiceWithTitle:LINKEDIN_TITLE
                     logoName:LINKEDIN_LOGO_IMAGE
              backgroundColor:LINKEDIN_BACKGROUND_COLOR()
                  borderColor:LINKEDIN_BORDER_COLOR()];
    [self addServiceWithTitle:SMS_TITLE
                     logoName:SMS_LOGO_IMAGE
              backgroundColor:SMS_BACKGROUND_COLOR()
                  borderColor:SMS_BORDER_COLOR()];
    [self addServiceWithTitle:EMAIL_TITLE
                     logoName:EMAIL_LOGO_IMAGE
              backgroundColor:EMAIL_BACKGROUND_COLOR()
                  borderColor:EMAIL_BORDER_COLOR()];
}

- (void)addServiceWithTitle:(NSString *)title
                   logoName:(NSString *)logoName
            backgroundColor:(UIColor *)backgroundColor
                borderColor:(UIColor *)borderColor
{
    ShareService *service = [[ShareService alloc] init];
    service.title = title;
    service.backgroundColor = backgroundColor;
    service.borderColor = borderColor;
    service.logo =  imageFromBundleNamed(logoName);
    
    [self.services addObject:service];
}

- (void)viewDidLoad {
    [self addServices];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [closeButton setImage:imageFromBundleNamed(@"close.png") forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.loader = [[ContactLoader alloc] initWithDelegate:self];
    });
    
    // Text Field Left padding view
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 12)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    // Text field Right clipboard view
    UIButton *clipboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 15)];
    [clipboardButton setImage:imageFromBundleNamed(@"clipboard") forState:UIControlStateNormal];
    [clipboardButton addTarget:self action:@selector(clipboardButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    self.textField.rightView = clipboardButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;

    
    [super viewDidLoad];
    self.titleLabel.text = self.prefs.titleLabelText;
    self.descriptionLabel.text = self.prefs.descriptionLabelText;
    self.textField.text = self.prefs.textFieldText;
    self.title = self.prefs.navBarTitle;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}



#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.services.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    ShareService *service = self.services[indexPath.row];
    
    cell.logoBackground.backgroundColor = service.backgroundColor;
    cell.logo.image = service.logo;
    cell.title .text= service.title;
    cell.logoBackground.layer.borderColor = service.borderColor.CGColor;
    cell.logoBackground.layer.borderWidth = CELL_BORDER_WIDTH;
    cell.logoBackground.layer.cornerRadius = CELL_CORNER_RADIUS;
    return cell;
}




#pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareService *service = self.services[indexPath.row];
    
    if ([service.title isEqualToString:FACEBOOK_TITLE])
    {
        //TODO:facebook
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [vc addURL:[NSURL URLWithString:self.shortURL]];
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"facebook" recipientUsername:@""];
            }
        };
        [vc setInitialText:self.prefs.defaultShareMessage];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([service.title isEqualToString:TWITTER_TITLE])
    {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [vc addURL:[NSURL URLWithString:self.shortURL]];
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"twitter" recipientUsername:@""];
            }
        };
        [vc setInitialText:self.prefs.defaultShareMessage];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([service.title isEqualToString:LINKEDIN_TITLE])
    {
        DLog();
        NSDictionary *token = [[NSUserDefaults  standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
        DLog(@"%@", token);
        if (token) {
            NSDate *referenceDate = token[LKDN_EXPIRES_DICT_KEY];
            if (!([referenceDate timeIntervalSinceNow] < 0.0))
            {
                DLog();
                [self presentLinkedIn];
            }
        }
        else
        {
            [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
        }
    }
    else if ([service.title isEqualToString:SMS_TITLE])
    {
        //TODO:sms
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:SMS_TITLE];
    }
    else if ([service.title isEqualToString:EMAIL_TITLE])
    {
        //TODO:email
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:EMAIL_TITLE];
    }
}

- (void)presentLinkedIn
{
    LinkedInShare * vc = [[LinkedInShare alloc] init];
    vc.defaultMessage = self.prefs.defaultShareMessage;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.shortCode = self.shortCode;
    vc.shortURL = self.shortURL;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CONTACT_SELECTOR_SEGUE])
    {
        ContactSelector *vc = (ContactSelector *)segue.destinationViewController;
        NSString *serviceType = (NSString *)sender;
        vc.prefs = self.prefs;
        vc.delegate = self;
        
        if ([serviceType isEqualToString:SMS_TITLE])
        {
            vc.data = self.loader.phoneNumbers;
            vc.serviceType = SMS_TITLE;
        }
        else if ([serviceType isEqualToString:EMAIL_TITLE])
        {
            vc.data = self.loader.emailAddresses;
            vc.serviceType = EMAIL_TITLE;
        }
    }
    else if ([segue.identifier isEqualToString:LKND_AUTHORIZE_SEGUE])
    {
        AuthorizeLinkedIn *vc = (AuthorizeLinkedIn *)segue.destinationViewController;
        vc.delegate = self;
    }
}

- (void)closeButtonPressed:(UIButton *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - ContactLoaderDelegate
- (void)contactsFailedToLoadWithError:(NSString *)errorTitle message:(NSString *)message
{
    [self simpleAlertWith:errorTitle message:message];
}



#pragma mark - Helper Functions
- (void)simpleAlertWith:(NSString*)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
    {
        //[self.presentingViewController dismissViewControllerAnimated:YES
                                                         // completion:nil];
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - Lkdn delegate
- (void)userDidContinue
{
    [self.navigationController popViewControllerAnimated:YES];
    [self presentLinkedIn];
}



#pragma mark - ShareServiceDelegate
- (void)networkError:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self simpleAlertWith:title message:message];
    });
    
}

- (void)userDidPostFromService:(NSString *)service
{
    DLog(@"Post succeeded");
    if ([service isEqualToString:LINKEDIN_TITLE])
    {
        [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"linkedin" recipientUsername:@""];
    }
}

- (void)userMustReauthenticate
{
    NSLog(@"Reauthenticate");
    
}



#pragma mark - TextField Activity Functions
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return NO; }

- (void)clipboardButtonPress:(UIButton *)button
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.textField.text];
}



#pragma mark - ContactSelectorDelegate
- (void)sendValues:(NSArray *)values forServiceType:(NSString *)serviceType
{
    [self bulkPostShareTrackWithShortCode:self.shortCode values:values socialName:serviceType];
}


#pragma mark - Share track
- (void)postShareTrackWithShortCode:(NSString *)shortCode recipientEmail:(NSString *)recipientEmail socialName:(NSString *)socialName recipientUsername:(NSString *)recipientUsername
{
    DLog();
    //Create payload
    NSDictionary *payload = @{ AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY : shortCode,
                               AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY : recipientEmail,
                               AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY : socialName,
                               AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY : recipientUsername };
    
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

- (void)bulkPostShareTrackWithShortCode:(NSString *)shortCode values:(NSArray *)values socialName:(NSString *)serviceType
{
    ShareTrackBulk *shareTrackObjects = [[ShareTrackBulk alloc] init];
    shareTrackObjects.bulk = [[NSMutableArray alloc] init];
    if ([serviceType isEqualToString:SMS_TITLE])
    {
        for (int i = 0; i < values.count; ++i)
        {
            ShareTrack * obj = [[ShareTrack alloc] init];
            obj.short_code = shortCode;
            obj.recipient_email = @"";
            obj.social_name = @"sms";
            obj.recipient_username = values[i];
            
            [shareTrackObjects.bulk addObject:obj];
        }
    }
    else if ([serviceType isEqualToString:EMAIL_TITLE])
    {
//        for (int i = 0; i < values.count; ++i)
//        {
//            [shareTrackObjects addObject:@{    AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY : shortCode,
//                                               AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY : values[i],
//                                               AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY : @"email",
//                                               AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY : @""
//                                               }];
//        }
    }
    
    
    NSURL *url = [NSURL URLWithString:AMB_SHARE_TRACK_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:AMB_AUTHORIZATION_TOKEN forHTTPHeaderField:@"Authorization"];
    
    DLog(@"%@", [shareTrackObjects toDictionary]);
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:[shareTrackObjects toDictionary] options:0 error:nil];
    
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      if (!error)
                                      {
                                          DLog(@"Status code for share track: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                                          
                                          //Check for 2xx status codes
                                          if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                                              ((NSHTTPURLResponse *)response).statusCode < 300)
                                          {
                                              // Looking for a "Polling" response
                                              DLog(@"Response from backend from sending share track: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
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
