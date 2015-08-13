//
//  ServiceSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
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
#import "Contact.h"
#import "AMBReachability.h"
#import "SendCompletionModal.h"
#import <MessageUI/MessageUI.h>


@interface ServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate,
                               ContactLoaderDelegate, LinkedInAuthorizeDelegate,
                               ShareServiceDelegate, ContactSelectorDelegate,
                               UITextFieldDelegate, MFMessageComposeViewControllerDelegate,
                               MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) ContactLoader *loader;
@property (strong, nonatomic) NSTimer *waitViewTimer;

@property NSString *singleEmail;
@property NSString *singleSMS;

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
        self.singleEmail = @"";
        self.singleSMS = @"";
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
    self.textField.delegate = self;

    
    [super viewDidLoad];
    self.titleLabel.text = self.prefs.titleLabelText;
    self.descriptionLabel.text = self.prefs.descriptionLabelText;
    self.textField.text = self.prefs.textFieldText;
    self.title = self.prefs.navBarTitle;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    DLog(@"%@", self.shortURL);
    if ((self.shortURL != nil) && ![self.shortURL isEqualToString:@""])
    {
        DLog();
        self.waitView.hidden = YES;
    }
    else
    {
        self.waitViewTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(alertForNetworkTimeout) userInfo:nil repeats:NO];
    }
}

- (void)alertForNetworkTimeout
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleWithIdentifier:@"com.ambassador.Framework"]];
    SendCompletionModal *vc = (SendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = @"The network request timed out. Please check your connection and try again";
    [vc shouldUseSuccessIcon:NO];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    __weak ServiceSelector *weakSelf = self;
    vc.buttonAction = ^() {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)removeWaitView
{
    if (self.waitViewTimer)
    {
        [self.waitViewTimer invalidate];
    }
    
    self.waitView.hidden = YES;
    self.textField.text = self.shortURL;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    sendAlert(YES, @"Your link was successfully shared", self);
                });
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    sendAlert(YES, @"Your link was successfully shared", self);
                });
                [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"twitter" recipientUsername:@""];
            }
        };
        [vc setInitialText:self.prefs.defaultShareMessage];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([service.title isEqualToString:LINKEDIN_TITLE])
    {
        DLog();
        [self checkLinkedInToken];
    }
    else if ([service.title isEqualToString:SMS_TITLE])
    {
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:SMS_TITLE];
    }
    else if ([service.title isEqualToString:EMAIL_TITLE])
    {
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:EMAIL_TITLE];
    }
}

- (void)checkLinkedInToken
{
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

- (void)presentLinkedIn
{
    DLog();
    LinkedInShare * vc = [[LinkedInShare alloc] init];
    DLog(@"%@", vc.debugDescription);
    vc.defaultMessage = self.prefs.defaultShareMessage;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.shortCode = self.shortCode;
    vc.shortURL = self.shortURL;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        DLog(@"finished presenting linkedIN");
    }];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CONTACT_SELECTOR_SEGUE])
    {
        ContactSelector *vc = (ContactSelector *)segue.destinationViewController;
        NSString *serviceType = (NSString *)sender;
        vc.prefs = self.prefs;
        vc.shortURL = self.shortURL;
        vc.shortCode = self.shortCode;
        vc.delegate = self;
        vc.defaultMessage = [NSString stringWithFormat:@"%@ %@", self.prefs.defaultShareMessage, self.shortURL];
        
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
//        [self simpleAlertWith:title message:message];
        sendAlert(NO, message, self);
    });
    
}

- (void)userDidPostFromService:(NSString *)service
{
    DLog(@"Post succeeded");
    if ([service isEqualToString:LINKEDIN_TITLE])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            sendAlert(YES, @"Your link was successfully shared", self);
        });
        [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"linkedin" recipientUsername:@""];
    }
}

- (void)userMustReauthenticate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"Reauthenticate");
        sendAlert(NO, @"You've been logged out of linkedIn. Log in and we will bring you back to the share screen.", self);
    });
}



#pragma mark - TextField Activity Functions
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return NO; }

- (void)clipboardButtonPress:(UIButton *)button
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.textField.text];
    
    UIButton *clipboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 15)];
    [clipboardButton setImage:imageFromBundleNamed(@"graycheck") forState:UIControlStateNormal];
    [clipboardButton addTarget:self action:@selector(clipboardButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    self.textField.rightView = clipboardButton;
}



#pragma mark - ContactSelectorDelegate
- (void)sendToContacts:(NSArray *)contacts forServiceType:(NSString *)serviceType fromName:(NSString *)name withMessage:(NSString *)message
{
    __weak NSString *shortCode = self.shortCode;
    __weak ServiceSelector *weakSelf = self;
    
    if ([serviceType isEqualToString:EMAIL_TITLE])
    {
        NSString *subjectLine = @"";
        NSArray *urls = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY][@"urls"];
        for (NSDictionary *url in urls)
        {
            if ([url[@"short_code"] isEqualToString:shortCode])
            {
                subjectLine = url[@"subject"];
                break;
            }
        }
        
        NSArray *validContacts = [weakSelf validateEmails:contacts];
        
        if (validContacts.count == 1)
        {
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            if ([MFMailComposeViewController canSendMail]) {
                vc.mailComposeDelegate = self;
                [vc setMessageBody:message isHTML:NO];
                [vc setSubject:subjectLine];
                [vc setToRecipients:validContacts];
                
                [self presentViewController:vc animated:YES completion:nil];
                self.singleEmail = [validContacts firstObject];
            }
            else
            {
                //sendAlert(NO, @"Your device doesn't support sending email.", self);
            }

            return;
        }
        
        NSDictionary *payload = @{
                                  @"to_emails" : validContacts,
                                  @"short_code" : shortCode,
                                  @"message" : message,
                                  @"subject_line" : subjectLine
                                  };
        
        
        NSLog(@"Email data sent to servers: %@", payload);
        
        NSURL *url = [NSURL URLWithString:AMB_EMAIL_SHARE_URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
        [request setValue:weakSelf.APIKey forHTTPHeaderField:@"Authorization"];
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              if (!error)
              {
                  NSLog(@"Status code for sending email: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                  
                  //Check for 2xx status codes
                  if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                      ((NSHTTPURLResponse *)response).statusCode < 300)
                  {
                      // Looking for a "Qued" response
                      NSLog(@"Response from backend from sending email: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                      [self sendSuccessMessageWithCount:validContacts.count];
                      [weakSelf bulkPostShareTrackWithShortCode:shortCode values:[weakSelf validateEmails:contacts] socialName:EMAIL_TITLE];
                  }
                  else
                  {
                      NSLog(@"Error: %@", error.localizedDescription);
                      sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
                  }
              }
              else
              {
                  NSLog(@"Error: %@", error.localizedDescription);
                   sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
              }
          }];
        [task resume];
    }
    else if ([serviceType isEqualToString:SMS_TITLE])
    {
        NSArray *validContacts = [weakSelf validatePhoneNumbers:contacts];
        NSDictionary *payload = @{
                                  @"to" : validContacts,
                                  @"name" : name,
                                  @"message" : message
                                  };
        
        NSLog(@"SMS data sent to servers %@", payload);
        
        if (validContacts.count == 1)
        {
            MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
            if ([MFMessageComposeViewController canSendText])
            {
                DLog(@"%@", vc);
                vc.messageComposeDelegate = self;
                [vc setBody:message];
                [vc setRecipients:validContacts];
                
                [self presentViewController:vc animated:YES completion:nil];
                self.singleSMS = [validContacts firstObject];
            }
            else
            {
                //sendAlert(NO, @"Your device doesn't support sending SMS", self);
            }
            return;
        }

        if (validContacts.count > 0 )
        {
            NSArray *components = [name componentsSeparatedByString:@" "];
            NSString *firstName = [components firstObject];
            NSString *lastName = [components lastObject];
            
            NSURL *url = [NSURL URLWithString:AMB_SMS_SHARE_URL];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
            [request setValue:weakSelf.APIKey forHTTPHeaderField:@"Authorization"];
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
            
            NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
              {
                  if (!error)
                  {
                      NSLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                      
                      //Check for 2xx status codes
                      if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                          ((NSHTTPURLResponse *)response).statusCode < 300)
                      {
                          // Looking for an echo response
                          NSLog(@"Response from backend from sending sms: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                          [self sendSuccessMessageWithCount:validContacts.count];
                          [weakSelf bulkPostShareTrackWithShortCode:shortCode values:[weakSelf validatePhoneNumbers:contacts] socialName:SMS_TITLE];
                      }
                      else
                      {
                          NSLog(@"Error: %@", error.localizedDescription);
                           sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
                      }
                  }
                  else
                  {
                      NSLog(@"Error: %@", error.localizedDescription);
                      dispatch_async(dispatch_get_main_queue(), ^{
                           sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
                      });
                  }
              }];
            [task resume];
            
            [self updateFirstName:firstName lastName:lastName];
        }
        else
        {
            NSLog(@"No valid numbers were selected");
        }
    }
}

- (void)sendSuccessMessageWithCount:(NSUInteger)count
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *message = [NSMutableString stringWithFormat:@"Your link was successfully shared to %ld contact", count];
        if (count != 1)
        {
            [message appendString:@"s"];
        }
        [message appendString:@"."];
        
        sendAlert(YES, message, self);
    });
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
    [request setValue:self.APIKey forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              NSLog(@"Status code: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  // Looking for a "echo" response
                  NSLog(@"Response from backend from sending share track: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
              }
          }
          else
          {
              NSLog(@"Error: %@", error.localizedDescription);
          }
      }];
    [task resume];
}

- (NSMutableArray *)validatePhoneNumbers:(NSArray *)contacts
{
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    for (Contact *contact in contacts)
    {
        NSString *number = [[contact.value componentsSeparatedByCharactersInSet:
                           [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]]
                             componentsJoinedByString:@""];
        if (number.length == 11 || number.length == 10 || number.length == 7)
        {
            [validSet addObject:number];
        }
    }
    return validSet;
}

- (NSMutableArray *)validateEmails:(NSArray *)contacts
{
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    for (Contact *contact in contacts)
    {
        NSString *number = contact.value;
        [validSet addObject:number];
    }
    return validSet;
}

- (void)bulkPostShareTrackWithShortCode:(NSString *)shortCode values:(NSArray *)values socialName:(NSString *)serviceType
{
    NSMutableArray *payload = [[NSMutableArray alloc] init];
    if ([serviceType isEqualToString:SMS_TITLE])
    {
        for (int i = 0; i < values.count; ++i)
        {
            NSDictionary* obj = @{
                                  AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY : shortCode,
                                  AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY : @"",
                                  AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY : @"sms",
                                  AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY : values[i]
                                  };
            
            [payload addObject:obj];
        }
    }
    else if ([serviceType isEqualToString:EMAIL_TITLE])
    {
        for (int i = 0; i < values.count; ++i)
        {
            [payload addObject:@{
                                 AMB_SHARE_TRACK_SHORT_CODE_DICT_KEY : shortCode,
                                 AMB_SHARE_TRACK_RECIPIENT_EMAIL_DICT_KEY : values[i],
                                 AMB_SHARE_TRACK_SOCIAL_NAME_DICT_KEY : @"email",
                                 AMB_SHARE_TRACK_RECIPIENT_USERNAME_DICT_KEY : @""
                                 }];
        }
    }
    
    NSURL *url = [NSURL URLWithString:AMB_SHARE_TRACK_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:self.APIKey forHTTPHeaderField:@"Authorization"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              NSLog(@"Status code for share track: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  // Looking for a "Polling" response
                  NSLog(@"Response from backend from sending bulk share track: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
              }
          }
          else
          {
              NSLog(@"Error: %@", error.localizedDescription);
          }
      }];
    [task resume];
}

- (void)updateFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    NSURL *url = [NSURL URLWithString:AMB_UPDATE_IDENTIFY_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AMB_MBSY_UNIVERSAL_ID forHTTPHeaderField:@"MBSY_UNIVERSAL_ID"];
    [request setValue:self.APIKey forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *ambassadorInfo = [[NSUserDefaults standardUserDefaults]
                       dictionaryForKey:AMB_AMBASSADOR_INFO_USER_DEFAULTS_KEY];
    NSString *email = ambassadorInfo[@"email"];
    NSLog(@"The user information during update: %@ %@ %@", email, firstName, lastName);
    
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setValue:email forKey:@"email"];
    NSDictionary *updateData = @{
                                   @"first_name" : firstName,
                                   @"last_name" : lastName
                                   };
    [payload setValue:updateData forKey:@"update_data"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              NSLog(@"Status code for share track: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
              
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  // Looking for a "Polling" response
                  NSLog(@"Response from backend from updating ambassador (looking for 'polling'): %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
              }
          }
          else
          {
              NSLog(@"Error: %@", error.localizedDescription);
          }
      }];
    [task resume];
}



#pragma mark - MFComposeViewController Delegates
- (void)mailComposeController:(nonnull MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    if (result == MFMailComposeResultFailed)
    {
        sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
    }
    else if (result == MFMailComposeResultSent)
    {
        sendAlert(NO, @"Your link was successfully shared", self);
        [self postShareTrackWithShortCode:self.shortCode recipientEmail:self.singleEmail socialName:@"email" recipientUsername:@""];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == MFMailComposeResultSaved || result == MFMailComposeResultCancelled)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultFailed)
    {
        sendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
    }
    else if (result == MessageComposeResultSent)
    {
        sendAlert(NO, @"Your link was successfully shared", self);
        [self postShareTrackWithShortCode:self.shortCode recipientEmail:@"" socialName:@"sms" recipientUsername:self.singleSMS];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == MessageComposeResultCancelled)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}




@end
