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
#import "AMBAuthorizeLinkedIn.h"
#import <Social/Social.h>
#import "AMBLinkedInShare.h"
#import "AMBThemeManager.h"
#import "AmbassadorSDK_Internal.h"
#import "AMBNetworkManager.h"
#import "AMBErrors.h"

@interface AMBServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LinkedInAuthorizeDelegate, AMBShareServiceDelegate, AMBUtilitiesDelegate>

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
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * shortURLBackgroundHeight;
@property (nonatomic, strong) IBOutlet UIButton * btnCopy;
@property (nonatomic, strong) IBOutlet UIView * shortURLBackground;

@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSTimer *waitViewTimer;
@property (nonatomic, strong) AMBUserUrlNetworkObject *urlNetworkObj;
@property (nonatomic, strong) UILabel * lblCopied;
@property (nonatomic, strong) NSTimer * copiedAnimationTimer;
@property (nonatomic) UIStatusBarStyle originalStatusBarTheme;
@property (nonatomic) BOOL attemptedAutoEnroll;

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
    [self performIdentityCheck];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.originalStatusBarTheme = [[UIApplication sharedApplication] statusBarStyle];
    [self setUpTheme];
    [self setUpCloseButton];
    
    self.services = [[AMBThemeManager sharedInstance] customSocialGridArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
    [AMBUtilities sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.waitViewTimer invalidate];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
    [[AMBUtilities sharedInstance] rotateLoadingView:self.view orientation:toInterfaceOrientation];
}

#pragma mark - IBActions

- (IBAction)clipboardButtonPress:(UIButton *)button{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.lblURL.text];
    if (!self.copiedAnimationTimer.isValid) { [self confirmCopyAnimation]; }
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
    
    // If the Info.plist value 'ViewController-based status bar is YES, we need to manually set the theme back to the original theme
    [[UIApplication sharedApplication] setStatusBarStyle: self.originalStatusBarTheme];
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
    [AMBErrors errorLinkedInShareForVC:self withMessage:message];
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
    [AMBErrors errorLinkedInReauthForVC:self];
}


#pragma mark - CustomAlert Delegate

- (void)okayButtonClickedForUniqueID:(NSString *)uniqueID {
    if ([uniqueID isEqualToString:@"linkedInAuth"]) {
        [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
    }
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

    // Set images programmatically
    [self.btnCopy setImage:[AMBValues imageFromBundleWithName:@"clipboard" type:@"png" tintable:NO] forState:UIControlStateNormal];

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
    
    // Setup shareURL field
    self.shortURLBackground.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ShareFieldBackgroundColor];
    self.lblURL.textColor = [[AMBThemeManager sharedInstance] colorForKey:ShareFieldTextColor];
    self.lblURL.font = [[AMBThemeManager sharedInstance] fontForKey:ShareFieldTextFont];
    self.shortURLBackgroundHeight.constant = [[[AMBThemeManager sharedInstance] sizeForKey:ShareFieldHeight] floatValue];
    self.btnCopy.backgroundColor = [[AMBThemeManager sharedInstance] colorForKey:ShareFieldBackgroundColor];
    self.shortURLBackground.layer.cornerRadius = [[[AMBThemeManager sharedInstance] sizeForKey:ShareFieldCornerRadius] floatValue];
    
    // Status bar
    [self setStatusBarTheme];
}

- (void)applyImage {
    NSMutableDictionary *imageDict = [[AMBThemeManager sharedInstance] imageForKey:RAFLogo];
    UIImage *image = [imageDict valueForKey:@"image"];
    
    int slotNum = [[imageDict valueForKey:@"imageSlotNumber"] intValue];
    
    switch (slotNum) {
        case 1:
            self.imgSlot1.image = image;
            self.imgSlotHeight1.constant = 70;
            break;
        case 2:
            self.imgSlot2.image = image;
            self.imgSlotHeight2.constant = 70;
            break;
        case 3:
            self.imgSlot3.image = image;
            self.imgSlotHeight3.constant = 70;
            break;
        case 4:
            self.imgSlot4.image = image;
            self.imgSlotHeight4.constant = 70;
            break;
        case 5:
            self.imgSlot5.image = image;
            self.imgSlotHeight5.constant = 70;
            break;
        default:
            break;
    }
}

- (void)setStatusBarTheme {
    // If the Info.plist value 'ViewController-based status bar is NO -- this works
    [[UIApplication sharedApplication] setStatusBarStyle: [[AMBThemeManager sharedInstance] statusBarTheme]];
    
    // If the Info.plist value 'ViewController-based status bar is YES -- this works
    UIBarStyle barStyle = [[AMBThemeManager sharedInstance] statusBarTheme] == UIStatusBarStyleLightContent ? UIBarStyleBlack : UIBarStyleDefault;
    self.navigationController.navigationBar.barStyle = barStyle;
}

- (void)setUpCloseButton {
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [closeButton setImage:[AMBValues imageFromBundleWithName:@"close" type:@"png" tintable:YES] forState:UIControlStateNormal];
    closeButton.tintColor = [[AMBThemeManager sharedInstance] colorForKey:NavBarTextColor];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (@available(iOS 9, *)) {
        [closeButton.widthAnchor constraintEqualToConstant: 16].active = YES;
        [closeButton.heightAnchor constraintEqualToConstant: 16].active = YES;
    }

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
    if ([AMBValues getLinkedInAccessToken] && ![AMBUtilities stringIsEmpty:[AMBValues getLinkedInAccessToken]]) {
        [self presentLinkedInShare];
    } else {
        [self performSegueWithIdentifier:LKND_AUTHORIZE_SEGUE sender:self];
    }
}

- (void)presentLinkedInShare {
    AMBLinkedInShare * vc = [[AMBLinkedInShare alloc] init];
    vc.defaultMessage = [[AMBThemeManager sharedInstance] messageForKey:DefaultShareMessage];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.shortCode = self.urlNetworkObj.short_code;
    vc.shortURL = self.urlNetworkObj.url;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    [vc didMoveToParentViewController:self];
}

- (void)alertForNetworkTimeout {
    [AMBErrors errorNetworkTimeoutForVC:self];
}

- (void)performIdentityCheck {
    // Checks to see if we have the user campaign list saved and attempts to load immediately
    if ([AMBValues getUserCampaignList]) {
        [self removeLoadingView];
    
    // Checks to make sure an identify process is NOT currently happening and attempts to auto-enroll user
    } else if (![AmbassadorSDK sharedInstance].identifyInProgress) {
        [self attemptAutoEnroll];
    
    // Here we can assume that an identify process is currently happening, so we just wait for it to finish
    } else {
        self.waitViewTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(alertForNetworkTimeout) userInfo:nil repeats:NO];
    }
}

- (void)removeLoadingView {
    NSNumber *campaignID = [NSNumber numberWithInt:self.campaignID.intValue];
    
    // Gets the current campaign info from the list based on the campID
    AMBUserNetworkObject *user = [AMBValues getUserCampaignList];
    self.urlNetworkObj = [user urlObjForCampaignID:campaignID];
    
    // Stores the specific campaign info to defaults
    [AMBValues setUserURLObject:[self.urlNetworkObj toDictionary]];
    
    // If the current campaign is nil and there is no pusher connection, we attempt to auto-enroll
    if (!self.urlNetworkObj && !self.attemptedAutoEnroll) {
        [self attemptAutoEnroll];
        return;
    }
    
    // This means that there was no matching campaigns based on the ID
    if (!self.urlNetworkObj && self.attemptedAutoEnroll) {
        [self.waitViewTimer invalidate];
        [AMBErrors errorAlertNoMatchingCampaignIdsForVC:self];
        [AMBErrors errorLogNoMatchingCampaignIdError:self.campaignID];
        return;
    }
    
    // Checks to make sure that the campaign is still active
    if (self.urlNetworkObj && !self.urlNetworkObj.is_active) {
        [self.waitViewTimer invalidate];
        [AMBErrors errorCampaignNoLongerActive:self];
        return;
    }
    
    // If it makes it past the checks, we finish loading the RAF
    [[AMBUtilities sharedInstance] hideLoadingView];
    self.lblURL.text = self.urlNetworkObj.url;
    if (self.waitViewTimer) { [self.waitViewTimer invalidate]; }
}

- (void)attemptAutoEnroll {
    DLog(@"[RAF] Attempting to auto enroll");
    self.attemptedAutoEnroll = YES;
    
    // Setup pusher connection and identify using shouldEnroll boolean with the designated campaign ID
    [[AmbassadorSDK sharedInstance] subscribeToPusherWithSuccess:^{
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

@end
