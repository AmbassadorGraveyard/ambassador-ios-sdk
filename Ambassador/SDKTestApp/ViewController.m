//
//  ViewController.m
//  SDKTestApp
//
//  Created by Matthew Majewski on 4/26/18.
//  Copyright © 2018 Ambassador. All rights reserved.
//

#import "ViewController.h"
#import <Ambassador/Ambassador.h>
#import <SafariServices/SafariServices.h>

@interface ViewController ()
@property (nonatomic, strong) SFSafariViewController * safariVC1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showShortCode:(id)sender {
    
    NSLog(@"showShortCode Clicked");
    NSString *short_code = [AmbassadorSDK getReferredByShortCode];
    self.myLabel.text = !([short_code  isEqual: @""]) ? short_code : @"No shortcode found.";
    self.outputText.text =!([short_code  isEqual: @""]) ? [NSString stringWithFormat:@"Short Code: %@", short_code] : @"No shortcode found.";
    NSLog(@"Short Code: %@", short_code);
}

- (IBAction)showCampaignId:(id)sender {
    NSLog(@"showCampaignId Clicked");
    NSString *campaign_uid = [AmbassadorSDK getCampaignIdFromShortCode:[AmbassadorSDK getReferredByShortCode]];
    self.outputText.text = !([campaign_uid  isEqual: @""]) ? [NSString stringWithFormat:@"Campaign: %@", campaign_uid] : @"No campaign found.";
    NSLog(@"Campaign: %@", campaign_uid);
}


- (IBAction)identifyAction:(id)sender {
    NSLog(@"identifyAction Clicked");
    
    NSDictionary *traitsDict = @{
                                 @"email" : @"matt+testios@getambassador.com",
                                 @"firstName" : @"iOS",
                                 @"lastName" : @"Test App",
                                 @"phone" : @"5555555",
                                 @"sandbox" : @NO,
                                 @"addToGroups": @"133",
                                 @"address" : @{
                                         @"street" : @"1 Main",
                                         @"city" : @"Detroit",
                                         @"state" : @"MI",
                                         @"postalCode" : @"48127",
                                         @"country" : @"USA"
                                         }
                                 };
    // Identify user
    [AmbassadorSDK identifyWithUserID:@"" traits:traitsDict completion:^(BOOL success){
        if (success){
            NSString *short_code = [AmbassadorSDK getReferredByShortCode];
            self.myLabel.text = !([short_code  isEqual: @""]) ? short_code : @"No shortcode found.";
            NSString *campaign_uid = [AmbassadorSDK getCampaignIdFromShortCode:short_code];
            self.outputText.text = [NSString stringWithFormat:@"Identify Callback successful! \nShortcode: %@. \nCampaign: %@.", short_code, campaign_uid];
            NSLog(@"Identify Callback successful! Shortcode: %@. Campaign: %@.", short_code, campaign_uid);
        }
        else{
            NSLog(@"callback not successful");
        }
        
    }];
}

- (IBAction)identifyNoEmailAction:(id)sender {
    NSLog(@"identifyNoEmailAction Clicked");
    
    NSDictionary *traitsDict = @{};
    
    // Identify user
    [AmbassadorSDK identifyWithUserID:@"" traits:traitsDict completion:^(BOOL success){
        if (success){
            NSString *short_code = [AmbassadorSDK getReferredByShortCode];
            NSString *campaign_uid = [AmbassadorSDK getCampaignIdFromShortCode:short_code];
            self.outputText.text = [NSString stringWithFormat:@"Identify (No Email) Callback successful! \nShortcode: %@. \nCampaign: %@", short_code, campaign_uid];
            NSLog(@"Callback successful! Shortcode: %@. Campaign: %@", short_code, campaign_uid);
        }
        else{
            NSLog(@"callback not successful");
        }
        
    }];
    
}

- (IBAction)unidentifyAction:(id)sender {
    NSLog(@"Unidentify Clicked");
    [AmbassadorSDK unidentify];
}

- (IBAction)getURLInfo:(id)sender {
    NSLog(@"getURLInfo clicked:");
    NSString *campaignId = [AmbassadorSDK getCampaignIdFromShortCode:@"jqhMS"];
    NSLog(@"%@", campaignId);
}

- (IBAction)svcGet:(id)sender {
    NSLog(@"svcGet:");
}

- (IBAction)showRAF:(id)sender {
    NSLog(@"RAF Clicked");
    [AmbassadorSDK presentRAFForCampaign:@"33451" FromViewController:self withThemePlist:@"Test RAF"];
}


- (IBAction)clickConversion:(id)sender {
    // Create dictionary for conversion properties
    NSDictionary *propertiesDictionary = @{
                                           @"campaign" : @33451,
                                           @"revenue" : @1,
                                           @"commissionApproved" : @YES,
                                           @"emailNewAmbassador" : @1,
                                           @"orderId" : @"",
                                           @"eventData1" : @"ios",
                                           @"eventData2" : @"",
                                           @"eventData3" : @""
                                           };
    
    
    [AmbassadorSDK trackEvent:@"Event Name" properties:propertiesDictionary completion:^(AMBConversionParameters *conversion, ConversionStatus conversionStatus, NSError *error) {
        switch (conversionStatus) {
            case ConversionSuccessful:
                NSLog(@"Success!");
                self.outputText.text = @"Successful Conversion Call";
                break;
            case ConversionPending:
                NSLog(@"Pending!");
                self.outputText.text = @"Pending Conversion Call";
                break;
            case ConversionError:
                NSLog(@"Error!");
                self.outputText.text = @"Error on Conversion Call";
                break;
            default:
                break;
        }
    }];
}

- (IBAction)showFingerprintValve:(id)sender {
    NSString *url_path = @"https://valve.github.io/fingerprintjs2/";
    self.safariVC1 = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url_path]];
    [self presentViewController:self.safariVC1 animated:YES completion:nil];
    
}


- (IBAction)showFingerprintBx:(id)sender {
    NSString *url_path = @"https://s3.amazonaws.com/ambassador-test/bx.html";
    self.safariVC1 = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url_path]];
    [self presentViewController:self.safariVC1 animated:YES completion:nil];
}



- (IBAction)getPlist:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GenericTheme" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"%@", path);
    NSLog(@"%@", dict);
    NSString *text = [dict valueForKey:@"LandingPageMessage"];
    NSLog(@"%@", text);
    self.outputText.text = [NSString stringWithFormat:@"%@ \n %@. \n %@", text, path, dict];
}

@end
