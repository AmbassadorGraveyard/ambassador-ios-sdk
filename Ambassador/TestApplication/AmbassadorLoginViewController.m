//
//  AmbassadorLoginViewController.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AmbassadorLoginViewController.h"
#import "DefaultsHandler.h"
#import <Ambassador/Ambassador.h>

@interface AmbassadorLoginViewController()

@property (nonatomic, strong) IBOutlet UIView * loginMasterView;
@property (nonatomic, strong) IBOutlet UITextField * tfUserName;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UIButton * btnNoAccount;

@end


@implementation AmbassadorLoginViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
}


#pragma mark - IBActions

- (IBAction)performLogin:(id)sender {
    [self makeAmbassadorLoginRequest];
}

#pragma mark - UI Functions

- (void)setupUI {
    // Login View
    self.loginMasterView.layer.cornerRadius = 6;
    
    // Login button
    self.btnLogin.layer.cornerRadius = 6;
}


#pragma mark - Helper Functions

- (void)makeAmbassadorLoginRequest {
    // Sets up request
    NSURL *ambassadorURL = [NSURL URLWithString:@"https://api.getambassador.com/v2-auth/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ambassadorURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *bodyDict = @{@"email" : self.tfUserName.text, @"password" : self.tfPassword.text};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil];
    
    // Makes network call
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [self isValidStatusCode:statusCode]) {
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            [self handleSuccessfulLogin:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not Sign In" message:@"There was an error when signing in. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }] resume];
}

- (BOOL)isValidStatusCode:(NSInteger)statusCode {
    return statusCode >= 200 && statusCode <= 299 ? YES : NO;
}

- (void)handleSuccessfulLogin:(NSDictionary*)dictionary {
    // Avatar
    [DefaultsHandler setUserImage:dictionary[@"company"][@"avatar_url"]];
    
    // Name
    NSString *firstName = dictionary[@"company"][@"first_name"];
    NSString *lastName = dictionary[@"company"][@"last_name"];
    [DefaultsHandler setFullName:firstName lastName:lastName];
    
    // Tokens
    NSString *sdkToken = [NSString stringWithFormat:@"SDKToken %@", dictionary[@"company"][@"sdk_token"]];
    [DefaultsHandler setSDKToken:sdkToken];
    [DefaultsHandler setUniversalID:dictionary[@"company"][@"universal_id"]];
    
    [AmbassadorSDK runWithUniversalToken:[DefaultsHandler getSDKToken] universalID:[DefaultsHandler getUniversalID]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
