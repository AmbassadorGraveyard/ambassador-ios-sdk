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


@interface ServiceSelector () <UICollectionViewDataSource, UICollectionViewDelegate,
                               ContactLoaderDelegate, LinkedInAuthorizeDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) ServiceSelectorPreferences *prefs;
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
    service.logo = [UIImage imageNamed:logoName];
    
    [self.services addObject:service];
}

- (void)viewDidLoad {
    [self addServices];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.loader = [[ContactLoader alloc] initWithDelegate:self];
    });
    
    [super viewDidLoad];
    self.titleLabel.text = self.prefs.textFieldText;
    
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
    }
    else if ([service.title isEqualToString:TWITTER_TITLE])
    {
        //TODO:twitter
    }
    else if ([service.title isEqualToString:LINKEDIN_TITLE])
    {
        //TODO:linkedin
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



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CONTACT_SELECTOR_SEGUE])
    {
        ContactSelector *vc = (ContactSelector *)segue.destinationViewController;
        NSString *serviceType = (NSString *)sender;
        
        if ([serviceType isEqualToString:SMS_TITLE])
        {
            vc.data = self.loader.phoneNumbers;
        }
        else if ([serviceType isEqualToString:EMAIL_TITLE])
        {
            vc.data = self.loader.emailAddresses;
        }
    }
    else if ([segue.identifier isEqualToString:LKND_AUTHORIZE_SEGUE])
    {
        AuthorizeLinkedIn *vc = (AuthorizeLinkedIn *)segue.destinationViewController;
        vc.delegate = self;
    }
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
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Lkdn delegate

@end
