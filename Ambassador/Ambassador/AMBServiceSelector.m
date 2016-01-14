//
//  ServiceSelector.m
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "AMBServiceSelector.h"
#import "AMBShareServiceCell.h"
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
#import "AMBNetworkManager.h"

@interface AMBServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LinkedInAuthorizeDelegate,
                                    AMBShareServiceDelegate, UITextFieldDelegate, AMBUtilitiesDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel * lblURL;
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
@property (nonatomic, strong) IBOutlet UIView * shortURLBackground;

@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSTimer *waitViewTimer;
@property (nonatomic, strong) AMBUserUrlNetworkObject *urlNetworkObj;
@property (nonatomic, strong) UILabel * lblCopied;
@property (nonatomic, strong) NSTimer * copiedAnimationTimer;

@end

@implementation AMBServiceSelector

NSString * const CONTACT_SELECTOR_SEGUE = @"goToContactSelector";
NSString * const LKND_AUTHORIZE_SEGUE = @"goToAuthorizeLinkedIn";
int contactServiceType;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AMBUtilities sharedInstance] showLoadingScreenForView:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingView) name:@"PusherReceived" object:nil]; // Subscribe to the notification that gets sent out when we get our pusher payload back
    self.waitViewTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(alertForNetworkTimeout) userInfo:nil repeats:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

    [self setUpTheme];
    [self setUpCloseButton];
    [self performIdentify];
    self.services = [[AMBThemeManager sharedInstance] customSocialGridArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.waitViewTimer invalidate];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
    
    CGFloat offset = [AMBUtilities getOffsetForRotation:self toOrientation:toInterfaceOrientation];
    [[AMBUtilities sharedInstance] rotateLoadingView:self.view widthOffset:offset];
}


#pragma mark - IBActions

- (IBAction)clipboardButtonPress:(UIButton *)button{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.lblURL.text];
    if (!self.copiedAnimationTimer.isValid) { [self confirmCopyAnimation]; }
}


#pragma mark - UI Functions

- (void)confirmCopyAnimation {
    if (!self.lblCopied) {
        self.lblCopied = [[UILabel alloc] initWithFrame:self.btnCopy.frame];
        self.lblCopied.accessibilityIdentifier = @"lblCopied";
    }
    
    self.lblCopied.alpha = 0;
    self.lblCopied.text = @"Copied!";
    self.lblCopied.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self.shortURLBackground addSubview:self.lblCopied];
    [self.shortURLBackground bringSubviewToFront:self.btnCopy];

    self.copiedAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideConfirmCopyAnimation) userInfo:nil repeats:NO];

    [UIView animateWithDuration:0.3 animations:^{
        self.lblCopied.frame = CGRectMake(self.btnCopy.frame.origin.x - self.lblCopied.frame.size.width - 20, self.lblCopied.frame.origin.y, 45, self.lblCopied.frame.size.height);
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

- (void)setUpTheme {
    [[AMBThemeManager sharedInstance] createDicFromPlist:self.themeName];
    // Sets labels and navbarTitle based on plist
    self.titleLabel.text = [[AMBThemeManager sharedInstance] messageForKey:RAFWelcomeTextMessage];
    self.descriptionLabel.text = [[AMBThemeManager sharedInstance] messageForKey:RAFDescriptionTextMessage];
    self.title = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    
    // Setup NAV BAR
    self.navigationController.navigationBar.barTintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor], NSFontAttributeName:[[AMBThemeManager sharedInstance] fontForKey:NavBarTextFont]};
    self.navigationController.title = [[AMBThemeManager sharedInstance] messageForKey:NavBarTextMessage];
    
    // Setup RAF Background color
    self.view.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:RAFBackgroundColor];
    
    // Setup RAF Labels
    self.titleLabel.textColor = [[AMBThemeManager sharedInstance] colorForKey:RAFWelcomeTextColor];
    self.titleLabel.font = [[AMBThemeManager sharedInstance] fontForKey:RAFWelcomeTextFont];
    self.descriptionLabel.textColor = [[AMBThemeManager sharedInstance] colorForKey:RAFDescriptionTextColor];
    self.descriptionLabel.font = [[AMBThemeManager sharedInstance] fontForKey:RAFDescriptionTextFont];
    [self applyImage];
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

- (void)setUpCloseButton {
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [closeButton setImage:[AMBValues imageFromBundleWithName:@"close" type:@"png" tintable:YES] forState:UIControlStateNormal];
    closeButton.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
}


#pragma mark - Helper Functions

- (void)stockShareWithSocialMediaType:(AMBSocialServiceType)servicetype {
    SLComposeViewController *vc;
    switch (servicetype) {
        case AMBSocialServiceTypeFacebook:
            vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            break;
        case AMBSocialServiceTypeTwitter:
            vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        default:
            break;
    }
    
    [vc addURL:[NSURL URLWithString:self.urlNetworkObj.url]];
    [vc setInitialText:[[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage]];
    [self presentViewController:vc animated:YES completion:nil];
    vc.completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Your link was shared successfully!" withUniqueID:@"stockShare" forViewController:self shouldDismissVCImmediately:NO];
            });

            [[AMBNetworkManager sharedInstance] sendShareTrackForServiceType:servicetype contactList:nil success:^(NSDictionary *response) {
                DLog(@"Share Track for %@ SUCCESSFUL with response - %@", [AMBOptions serviceTypeStringValue:servicetype], response);
            } failure:^(NSString *error) {
                DLog(@"Share Track for %@ FAILED with response - %@", [AMBOptions serviceTypeStringValue:servicetype], error);
            }];
        }
    };
}

- (void)checkLinkedInToken {
    [[AMBNetworkManager sharedInstance] checkForInvalidatedTokenWithCompletion:^{
        if ([AMBValues getLinkedInAccessToken]) {
            [self presentLinkedInShare];
        } else {
            [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
        }
    }];
}

- (void)presentLinkedInShare {
    DLog();
    AMBLinkedInShare * vc = [[AMBLinkedInShare alloc] init];
    DLog(@"%@", vc.debugDescription);
    vc.defaultMessage = [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.shortCode = self.urlNetworkObj.short_code;
    vc.shortURL = self.urlNetworkObj.url;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    [vc didMoveToParentViewController:self];
}

- (void)alertForNetworkTimeout {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"The network request has timed out. Please check your connection and try again." withUniqueID:@"networkTimeOut" forViewController:self shouldDismissVCImmediately:YES];
    [AMBUtilities sharedInstance].delegate = self;
}

- (void)removeLoadingView {
    NSNumber *campaingID = [NSNumber numberWithInt:self.campaignID.intValue];
    self.urlNetworkObj = [[AmbassadorSDK sharedInstance].user urlObjForCampaignID:campaingID];
    [AMBValues setUserURLObject:[self.urlNetworkObj toDictionary]];
    
    if (!self.urlNetworkObj) { // This means that there was no matching campaign ID that was returned
        [self.waitViewTimer invalidate];
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"No matching campaigns were found!" withUniqueID:nil forViewController:self shouldDismissVCImmediately:YES];
        [AMBUtilities sharedInstance].delegate = self;
        NSLog(@"There were no Campaign IDs found matching '%@'.  Please make sure that the correct Campaign ID is being passed when presenting the RAF view controller.", self.campaignID);
        return;
    }

    [[AMBUtilities sharedInstance] hideLoadingView];
    self.lblURL.text = self.urlNetworkObj.url;
    if (self.waitViewTimer) { [self.waitViewTimer invalidate]; }
}

- (void)performIdentify {
    AMBPusherChannelObject *channelObject = [AMBValues getPusherChannelObject];
    
    // Checks if we are subscribed to a pusher channel and makes sure that the channel is not expired
    if (channelObject && !channelObject.isExpired && [AmbassadorSDK sharedInstance].pusherManager.connectionState == PTPusherConnectionConnected) {
        // If we're SUBSCRIBED and NOT expired, then we will call the Identify
        [self sendIdentify];
        return;
    }
    
    // Checks if we are subscribed, good with expiration, BUT Pusher got disconnected
    if (channelObject && !channelObject.isExpired && [AmbassadorSDK sharedInstance].pusherManager.connectionState != PTPusherConnectionConnected) {
        // If pusher socket is NOT OPEN, then we attempt to RESUBSCRIBE to the existing channel
        DLog(@"Attempting to resubscribe to previous Pusher channel");
        [[AmbassadorSDK sharedInstance].pusherManager resubscribeToExistingChannelWithCompletion:^(AMBPTPusherChannel *channelName, NSError *error) {
            if (error) {
                DLog(@"Error resubscribing to channel - %@", error); // If there is an error trying to resubscribe, we will recall the whole identify process
                [[AmbassadorSDK sharedInstance] subscribeToPusherWithCompletion:^{
                    [self sendIdentify];
                }];
            } else {
                [self sendIdentify];
            }
        }];
        
        return;
    }
    
    // If we're NOT SUBSCRIBED or EXPIRED then we will do the whole pusher process over again (get channel name, connect to pusher, subscribe, identify)
    DLog(@"The Pusher channel seems to be null or expired, restarting whole identify process");
    [[AmbassadorSDK sharedInstance] subscribeToPusherWithCompletion:^{
        [self sendIdentify];
    }];
}

- (void)sendIdentify {
    [[AMBNetworkManager sharedInstance] sendIdentifyForCampaign:self.campaignID shouldEnroll:YES success:^(NSString *response) {
        DLog(@"SEND IDENTIFY Response - %@", response);
    } failure:^(NSString *error) {
        DLog(@"SEND IDENTIFY Response - %@", error);
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CONTACT_SELECTOR_SEGUE]) {
        AMBContactSelector *vc = (AMBContactSelector *)segue.destinationViewController;
        vc.shortURL = self.urlNetworkObj.url;
        vc.shortCode = self.urlNetworkObj.short_code;
        vc.defaultMessage = [NSString stringWithFormat:@"%@ %@", [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage], self.urlNetworkObj.url];
        vc.type = contactServiceType;
        vc.urlNetworkObject = self.urlNetworkObj;
    } else if ([segue.identifier isEqualToString:LKND_AUTHORIZE_SEGUE]) {
        AMBAuthorizeLinkedIn *vc = (AMBAuthorizeLinkedIn *)segue.destinationViewController;
        vc.delegate = self;
    }
}

- (void)closeButtonPressed:(UIButton *)button {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.services count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBShareServiceCell *cell = (AMBShareServiceCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"serviceCell" forIndexPath:indexPath];
    [cell setUpCellWithCellType:[AMBThemeManager enumValueForSocialString:self.services[indexPath.row]]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/3, 105);
}


#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBShareServiceCell *selectedCell = (AMBShareServiceCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    switch (selectedCell.cellType) {
        case Facebook:
            [self stockShareWithSocialMediaType:AMBSocialServiceTypeFacebook];
            break;
        case Twitter:
            [self stockShareWithSocialMediaType:AMBSocialServiceTypeTwitter];
            break;
        case LinkedIn:
            [self checkLinkedInToken];
            break;
        case SMS:
            contactServiceType = AMBSocialServiceTypeSMS;
            [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:self];
            break;
        case Email:
            contactServiceType = AMBSocialServiceTypeEmail;
            [self performSegueWithIdentifier:CONTACT_SELECTOR_SEGUE sender:self];
            break;
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBShareServiceCell *selectedCell = (AMBShareServiceCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        selectedCell.backgroundColor = [UIColor cellSelectionGray];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    AMBShareServiceCell *selectedCell = (AMBShareServiceCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        selectedCell.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:RAFBackgroundColor];
    }];
}


#pragma mark - Linkedin delegate

- (void)userDidContinue {
    [self.navigationController popViewControllerAnimated:YES];
    [self presentLinkedInShare];
}


#pragma mark - ShareServiceDelegate

- (void)networkError:(NSString *)title message:(NSString *)message {
    [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:message withUniqueID:@"linkedShareFail" forViewController:self shouldDismissVCImmediately:NO];
}

- (void)userDidPostFromService:(NSString *)service {
    if ([service isEqualToString:@"LinkedIn"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AMBUtilities sharedInstance] presentAlertWithSuccess:YES message:@"Your link was successfully shared" withUniqueID:@"linkedInShare" forViewController:self shouldDismissVCImmediately:NO];
        });

        [[AMBNetworkManager sharedInstance] sendShareTrackForServiceType:AMBSocialServiceTypeLinkedIn contactList:nil success:^(NSDictionary *response) {
            DLog(@"LINKEDIN Share Track SUCCESSFUL with response - %@", response);
        } failure:^(NSString *error) {
            DLog(@"LINKEDIN Share Track FAILED with response - %@", error);
        }];
    }
}

- (void)userMustReauthenticate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AMBUtilities sharedInstance] presentAlertWithSuccess:NO message:@"You've been logged out of LinkedIn. Please login to share." withUniqueID:@"linkedInAuth" forViewController:self shouldDismissVCImmediately:NO];
        [AMBUtilities sharedInstance].delegate = self;
    });
}



- (void)okayButtonClickedForUniqueID:(NSString *)uniqueID {
    if ([uniqueID isEqualToString:@"linkedInAuth"]) {
        [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
    }
}

@end
