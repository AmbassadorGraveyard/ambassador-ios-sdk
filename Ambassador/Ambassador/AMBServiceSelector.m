//
//  ServiceSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBServiceSelector.h"
#import "AMBShareServiceCell.h"
#import "AMBShareService.h"
#import "AMBShareServicesConstants.h"
#import "AMBContactSelector.h"
#import "AMBContactLoader.h"
#import "AMBAuthorizeLinkedIn.h"
#import "AMBUtilities.h"
#import "AMBLinkedInAPIConstants.h"
#import "AMBConstants.h"
#import <Social/Social.h>
#import "AMBLinkedInShare.h"
#import "AMBContact.h"
#import "AMBSendCompletionModal.h"
#import <MessageUI/MessageUI.h>
#import "AMBIdentify.h"
#import "AMBThemeManager.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBNetworkObject.h"
#import "AMBAmbassadorNetworkManager.h"


@interface AMBServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate,
                               AMBContactLoaderDelegate, LinkedInAuthorizeDelegate,
                               AMBShareServiceDelegate,
                               UITextFieldDelegate, MFMessageComposeViewControllerDelegate,
                               MFMailComposeViewControllerDelegate, AMBUtilitiesDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot1;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot2;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot3;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot4;
@property (nonatomic, strong) IBOutlet UIImageView *imgSlot5;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight1;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight2;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight3;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight4;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imgSlotHeight5;
@property (nonatomic, strong) IBOutlet UIButton * btnCopy;

@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) AMBContactLoader *loader;
@property (nonatomic, strong) NSTimer *waitViewTimer;
@property (nonatomic, strong) AMBUserUrlNetworkObject *urlNetworkObj;
//@property (nonatomic, strong) NSString *singleEmail;
//@property (nonatomic, strong) NSString *singleSMS;
@property (nonatomic, strong) UILabel * lblCopied;
@property (nonatomic, strong) NSTimer * copiedAnimationTimer;

@end

@implementation AMBServiceSelector

#pragma mark -
NSString * const CELL_IDENTIFIER = @"serviceCell";
NSString * const CONTACT_SELECTOR_SEGUE = @"goToContactSelector";
NSString * const LKND_AUTHORIZE_SEGUE = @"goToAuthorizeLinkedIn";
float const CELL_BORDER_WIDTH = 2.0;
float const CELL_CORNER_RADIUS = CELL_BORDER_WIDTH;



#pragma mark - Initialization

//- (id)init
//{
//    if ([super init])
//    {
////        self.singleEmail = @"";
//        self.singleSMS = @"";
//        
//    }
//    
//    return self;
//}

- (void)addServices
{
    if (!self.services) { self.services = [[NSMutableArray alloc] init]; }
    
    [self addServiceWithTitle:AMB_FACEBOOK_TITLE
                     logoName:AMB_FACEBOOK_LOGO_IMAGE
              backgroundColor:AMB_FACEBOOK_BACKGROUND_COLOR()
                  borderColor:AMB_FACEBOOK_BORDER_COLOR()];
    [self addServiceWithTitle:AMB_TWITTER_TITLE
                     logoName:AMB_TWITTER_LOGO_IMAGE
              backgroundColor:AMB_TWITTER_BACKGROUND_COLOR()
                  borderColor:AMB_TWITTER_BORDER_COLOR()];
    [self addServiceWithTitle:AMB_LINKEDIN_TITLE
                     logoName:AMB_LINKEDIN_LOGO_IMAGE
              backgroundColor:AMB_LINKEDIN_BACKGROUND_COLOR()
                  borderColor:AMB_LINKEDIN_BORDER_COLOR()];
    [self addServiceWithTitle:AMB_SMS_TITLE
                     logoName:AMB_SMS_LOGO_IMAGE
              backgroundColor:AMB_SMS_BACKGROUND_COLOR()
                  borderColor:AMB_SMS_BORDER_COLOR()];
    [self addServiceWithTitle:AMB_EMAIL_TITLE
                     logoName:AMB_EMAIL_LOGO_IMAGE
              backgroundColor:AMB_EMAIL_BACKGROUND_COLOR()
                  borderColor:AMB_EMAIL_BORDER_COLOR()];
}

- (void)addServiceWithTitle:(NSString *)title
                   logoName:(NSString *)logoName
            backgroundColor:(UIColor *)backgroundColor
                borderColor:(UIColor *)borderColor
{
    AMBShareService *service = [[AMBShareService alloc] init];
    service.title = title;
    service.backgroundColor = backgroundColor;
    service.borderColor = borderColor;
    service.logo =  AMBimageFromBundleNamed(logoName, @"png");
    
    [self.services addObject:service];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AMBUtilities sharedInstance] showLoadingScreenWithText:@"Loading" forView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeWaitView) name:@"PusherReceived" object:nil];
    [self addServices];
    
    // Set the navigation bar attributes (title and back button)
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [closeButton setImage:[AMBimageFromBundleNamed(@"close", @"png") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    closeButton.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.loader = [[AMBContactLoader alloc] initWithDelegate:self];
    });
    
    // Text Field Left padding view
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 12)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    // Text field Right clipboard view
//    UIButton *clipboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 15)];
//    [clipboardButton setImage:AMBimageFromBundleNamed(@"clipboard", @"png") forState:UIControlStateNormal];
//    [clipboardButton addTarget:self action:@selector(clipboardButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    self.textField.rightView = clipboardButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    self.textField.delegate = self;

    self.titleLabel.text = self.prefs.titleLabelText;
    self.descriptionLabel.text = self.prefs.descriptionLabelText;
    self.textField.text = self.prefs.textFieldText;
    self.title = self.prefs.navBarTitle;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
//    self.lblCopied = [[UILabel alloc] initWithFrame:self.]
    
    DLog(@"%@", self.urlNetworkObj.short_code);

    self.waitViewTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(alertForNetworkTimeout) userInfo:nil repeats:NO];
    
    [self performIdentify];
    
    [self setUpTheme];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.waitViewTimer invalidate];
}

- (void)alertForNetworkTimeout
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:AMBframeworkBundle()];
    AMBSendCompletionModal *vc = (AMBSendCompletionModal *)[sb instantiateViewControllerWithIdentifier:@"sendCompletionModal"];
    vc.alertMessage = @"The network request timed out. Please check your connection and try again";
    [vc shouldUseSuccessIcon:NO];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    __weak AMBServiceSelector *weakSelf = self;
    vc.buttonAction = ^() {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)removeWaitView
{
    NSNumber *campaingID = [NSNumber numberWithInt:self.campaignID.intValue];
    self.urlNetworkObj = [[AmbassadorSDK sharedInstance].user urlObjForCampaignID:campaingID];
    
    if (!self.urlNetworkObj) {
        [self.waitViewTimer invalidate];
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"No matching campaigns were found!" forViewController:self];
        [AMBUtilities sharedInstance].delegate = self;
        NSLog(@"There were no Campaign IDs found matching '%@'.  Please make sure that the correct Campaign ID is being passed when presenting the RAF view controller.", self.campaignID);
        return;
    }
    
    [[AMBUtilities sharedInstance] hideLoadingView];
    
    self.textField.text = self.urlNetworkObj.url;
    
    if (self.waitViewTimer)
    {
        [self.waitViewTimer invalidate];
    }
}

- (void)performIdentify {
    AMBPusherChannelObject *channelObject = [AmbassadorSDK sharedInstance].pusherChannelObj;
    
    // Checks if we are subscribed to a pusher channel and makes sure that the channel is not expired
    if (channelObject && !channelObject.isExpired && [AmbassadorSDK sharedInstance].pusherManager.connectionState == PTPusherConnectionConnected) {
        // If we're SUBSCRIBED and NOT expired, then we will call the Identify
        [AmbassadorSDK sendIdentifyWithCampaign:self.campaignID enroll:YES completion:^(NSError *e) {
            if (e) { DLog(@"There was an error - %@", e); }
        }];
        
        return;
    }
    
    // Checks if we are subscribed, good with expiration, BUT Pusher got disconnected
    if (channelObject && !channelObject.isExpired && [AmbassadorSDK sharedInstance].pusherManager.connectionState != PTPusherConnectionConnected) {
        // If pusher socket is NOT OPEN, then we attempt to RESUBSCRIBE to the existing channel
        DLog(@"Attempting to resubscribe to previous Pusher channel");
        [[AmbassadorSDK sharedInstance].pusherManager resubscribeToExistingChannelWithCompletion:^(AMBPTPusherChannel *channelName, NSError *error) {
            if (error) {
                DLog(@"Error resubscribing to channel - %@", error); // If there is an error trying to resubscribe, we will recall the whole identify process
                [AmbassadorSDK identifyWithEmail:[AmbassadorSDK sharedInstance].email completion:^(NSError *e) {
                    [AmbassadorSDK sendIdentifyWithCampaign:self.campaignID enroll:YES completion:^(NSError *e) {
                        if (e) { DLog(@"There was an error - %@", e); }
                    }];
                }];
            } else {
                [AmbassadorSDK sendIdentifyWithCampaign:self.campaignID enroll:YES completion:nil]; // Everything is good to go and we can call identify
            }
        }];
        
        return;
    }

    // If we're NOT SUBSCRIBED or EXPIRED then we will do the whole pusher process over again (get channel name, connect to pusher, subscribe, identify)
    DLog(@"The Pusher channel seems to be null or expired, restarting whole identify process");
    [AmbassadorSDK identifyWithEmail:[AmbassadorSDK sharedInstance].email completion:^(NSError *e) {
        [AmbassadorSDK sendIdentifyWithCampaign:self.campaignID enroll:YES completion:^(NSError *e) {
            if (e) {
                DLog(@"There was an error - %@", e);
            }
        }];
    }];
}


#pragma mark - IBActions

- (IBAction)clipboardButtonPress:(UIButton *)button{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.textField.text];
    if (!self.copiedAnimationTimer.isValid) { [self confirmCopyAnimation]; }
}

- (void)confirmCopyAnimation {
    if (!self.lblCopied) { self.lblCopied = [[UILabel alloc] initWithFrame:self.btnCopy.frame]; }
    self.lblCopied.alpha = 0;
    self.lblCopied.text = @"Copied!";
    self.lblCopied.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self.view addSubview:self.lblCopied];
    [self.view bringSubviewToFront:self.btnCopy];

    self.copiedAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideConfirmCopyAnimation) userInfo:nil repeats:NO];
    self.copiedAnimationTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];

    [UIView animateWithDuration:0.3 animations:^{
        self.lblCopied.frame = CGRectMake(self.btnCopy.frame.origin.x - self.lblCopied.frame.size.width - 7, self.lblCopied.frame.origin.y, 45, self.lblCopied.frame.size.height);
        self.lblCopied.alpha = 1;
    }];
}

- (void)hideConfirmCopyAnimation {
    [self.copiedAnimationTimer invalidate];
    [UIView animateWithDuration:0.3 animations:^{
        self.lblCopied.frame = self.btnCopy.frame;
        self.lblCopied.alpha = 0;
    }];
}


#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.services.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AMBShareServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    AMBShareService *service = self.services[indexPath.row];
    
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
    AMBShareService *service = self.services[indexPath.row];
    __weak AMBServiceSelector *weakSelf = self;
    if ([service.title isEqualToString:AMB_FACEBOOK_TITLE])
    {
        //TODO:facebook
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [vc addURL:[NSURL URLWithString:self.urlNetworkObj.url]];
        __weak AMBServiceSelector *weakSelf = self;
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                dispatch_async(dispatch_get_main_queue(), ^{
                    AMBsendAlert(YES, @"Your link was successfully shared", self);
                });
                
                [weakSelf sendShareTrackForServiceType:AMBSocialServiceTypeFacebook completion:^(NSData *d, NSURLResponse *r, NSError *e) {
                    DLog(@"Error for sending share track: %@\n Body returned for sending share track: %@", e, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
                }];
            }
        };
        [vc setInitialText:self.prefs.defaultShareMessage];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([service.title isEqualToString:AMB_TWITTER_TITLE])
    {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [vc addURL:[NSURL URLWithString:self.urlNetworkObj.url]];
        vc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                DLog();
                dispatch_async(dispatch_get_main_queue(), ^{
                    AMBsendAlert(YES, @"Your link was successfully shared", self);
                });
                [weakSelf sendShareTrackForServiceType:AMBSocialServiceTypeTwitter completion:^(NSData *d, NSURLResponse *r, NSError *e) {
                    DLog(@"Error for sending share track: %@\n Body returned for sending share track: %@", e, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
                }];
            }
        };
        [vc setInitialText:self.prefs.defaultShareMessage];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([service.title isEqualToString:AMB_LINKEDIN_TITLE])
    {
        DLog();
        [self checkLinkedInToken];
    }
    else if ([service.title isEqualToString:AMB_SMS_TITLE])
    {
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:[NSNumber numberWithInt:AMBSocialServiceTypeSMS]];
    }
    else if ([service.title isEqualToString:AMB_EMAIL_TITLE])
    {
        [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:[NSNumber numberWithInt:AMBSocialServiceTypeEmail]];
    }
}

- (void)sendShareTrackForServiceType:(AMBSocialServiceType)type completion:(void(^)(NSData *, NSURLResponse *, NSError *))c {
    __weak AMBServiceSelector *weakSelf = self;
    AMBShareTrackNetworkObject *share = [[AMBShareTrackNetworkObject alloc] init];
    share.short_code = weakSelf.urlNetworkObj.short_code;
    share.social_name = socialServiceTypeStringVal(type);
    [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:c];
    
    
}

- (void)checkLinkedInToken
{
    NSDictionary *token = [[NSUserDefaults  standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
    DLog(@"%@", token);
    if (token) {
        NSDate *referenceDate = token[AMB_LKDN_EXPIRES_DICT_KEY];
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
    AMBLinkedInShare * vc = [[AMBLinkedInShare alloc] init];
    DLog(@"%@", vc.debugDescription);
    vc.defaultMessage = self.prefs.defaultShareMessage;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.shortCode = self.urlNetworkObj.short_code;
    vc.shortURL = self.urlNetworkObj.url;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    [vc didMoveToParentViewController:self];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CONTACT_SELECTOR_SEGUE])
    {
        NSNumber *serviceTypeNum = (NSNumber *)sender;
        AMBSocialServiceType type = [serviceTypeNum intValue];
        AMBContactSelector *vc = (AMBContactSelector *)segue.destinationViewController;
        vc.prefs = self.prefs;
        vc.shortURL = self.urlNetworkObj.url;
        vc.shortCode = self.urlNetworkObj.short_code;
        vc.delegate = self;
        vc.defaultMessage = [NSString stringWithFormat:@"%@ %@", self.prefs.defaultShareMessage, self.urlNetworkObj.url];
        vc.type = type;
        vc.urlNetworkObject = self.urlNetworkObj;
        if (type == AMBSocialServiceTypeSMS)
        {
            vc.data = self.loader.phoneNumbers;
        }
        else if (type ==AMBSocialServiceTypeEmail)
        {
            vc.data = self.loader.emailAddresses;
        }
    }
    else if ([segue.identifier isEqualToString:LKND_AUTHORIZE_SEGUE])
    {
        AMBAuthorizeLinkedIn *vc = (AMBAuthorizeLinkedIn *)segue.destinationViewController;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)setUpTheme {
    // Setup NAV BAR
    self.navigationController.navigationBar.barTintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                NSForegroundColorAttributeName:[[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor],
                NSFontAttributeName:[[AMBThemeManager sharedInstance] fontForKey:NavBarTextFont]};
    self.navigationController.title = self.prefs.navBarTitle;
    
    
    // Setup RAF Background color
    self.view.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:RAFBackgroundColor];
    
    // Setup RAF Labels
    self.titleLabel.textColor = [[AMBThemeManager sharedInstance] colorForKey:RAFWelcomeTextColor];
    self.titleLabel.font = [[AMBThemeManager sharedInstance] fontForKey:RAFWelcomeTextFont];
    self.descriptionLabel.textColor = [[AMBThemeManager sharedInstance] colorForKey:RAFDescriptionTextColor];
    self.descriptionLabel.font = [[AMBThemeManager sharedInstance] fontForKey:RAFDescriptionTextFont];
    [self applyImage];
//    if ([[AMBThemeManager sharedInstance] imageForKey:RAFLogo].imageAsset) {
//        self.imgLogo.image = [[AMBThemeManager sharedInstance] imageForKey:RAFLogo];
//    } else {
//        self.imgLogoHeight.constant = 0;
//    }
}

- (void)applyImage {
    NSMutableDictionary *imageDict = [[AMBThemeManager sharedInstance] imageForKey:RAFLogo];
    UIImage *image = [imageDict valueForKey:@"image"];
    
    int slotNum = [[imageDict valueForKey:@"imageSlotNumber"] intValue];
    
    switch (slotNum) {
        case 1:
            self.imgSlot1.image = image;
            self.imgSlotHeight1.constant = 50;
            break;
            
        case 2:
            self.imgSlot2.image = image;
            self.imgSlotHeight2.constant = 50;
            break;
            
        case 3:
            self.imgSlot3.image = image;
            self.imgSlotHeight3.constant = 50;
            break;
            
        case 4:
            self.imgSlot4.image = image;
            self.imgSlotHeight4.constant = 50;
            break;
            
        case 5:
            self.imgSlot5.image = image;
            self.imgSlotHeight5.constant = 50;
            break;
            
        default:
            break;
    }
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
        AMBsendAlert(NO, message, self);
    });
    
}

- (void)userDidPostFromService:(NSString *)service
{
    DLog(@"Post succeeded");
    if ([service isEqualToString:AMB_LINKEDIN_TITLE])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            AMBsendAlert(YES, @"Your link was successfully shared", self);
        });
        [self sendShareTrackForServiceType:AMBSocialServiceTypeLinkedIn completion:^(NSData *d, NSURLResponse *r, NSError *e) {
            DLog(@"Error for sending share track: %@\n Body returned for sending share track: %@", e, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
        }];
    }
}

- (void)userMustReauthenticate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"Reauthenticate");
        AMBsendAlert(NO, @"You've been logged out of linkedIn. Log in and we will bring you back to the share screen.", self);
        [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
    });
}



#pragma mark - TextField Activity Functions
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return NO; }




- (void)sendSuccessMessageWithCount:(NSUInteger)count
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *message = [NSMutableString stringWithFormat:@"Your link was successfully shared to %ld contact", (unsigned long)count];
        if (count != 1)
        {
            [message appendString:@"s"];
        }
        [message appendString:@"."];
        
        AMBsendAlert(YES, message, self);
    });
}

//
//#pragma mark - MFComposeViewController Delegates
//- (void)mailComposeController:(nonnull MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
//{
//    if (result == MFMailComposeResultFailed)
//    {
//        AMBsendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
//    }
//    else if (result == MFMailComposeResultSent)
//    {
//        AMBsendAlert(NO, @"Your link was successfully shared", self);
//        AMBShareTrackNetworkObject *share = [[AMBShareTrackNetworkObject alloc] init];
//        share.recipient_email = [NSMutableArray arrayWithObject:self.singleEmail];
//        share.short_code = self.urlNetworkObj.short_code;
//        share.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeEmail);
//        
//        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//            DLog(@"Error for sending share track: %@\n Body returned for sending share track: %@", e, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
//        }];
//        
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    }
//    else if (result == MFMailComposeResultSaved || result == MFMailComposeResultCancelled)
//    {
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//{
//    if (result == MessageComposeResultFailed)
//    {
//        AMBsendAlert(NO, @"We couldn't send your messages right now. Please check your network connection and try again.", self);
//    }
//    else if (result == MessageComposeResultSent)
//    {
//        AMBsendAlert(NO, @"Your link was successfully shared", self);
//        
//        AMBShareTrackNetworkObject *share = [[AMBShareTrackNetworkObject alloc] init];
//        share.recipient_username = [NSMutableArray arrayWithObject:self.singleSMS];
//        share.short_code = self.urlNetworkObj.short_code;
//        share.social_name = socialServiceTypeStringVal(AMBSocialServiceTypeSMS);
//        
//        [[AMBAmbassadorNetworkManager sharedInstance] sendNetworkObject:share url:[AMBAmbassadorNetworkManager sendShareTrackUrl] additionParams:nil requestType:@"POST" completion:^(NSData *d, NSURLResponse *r, NSError *e) {
//            DLog(@"Error for sending share track: %@\n Body returned for sending share track: %@", e, [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding]);
//        }];
//
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    }
//    else if (result == MessageComposeResultCancelled)
//    {
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    }
//}


#pragma mark - AMBUtilities Delegate

- (void)okayButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
