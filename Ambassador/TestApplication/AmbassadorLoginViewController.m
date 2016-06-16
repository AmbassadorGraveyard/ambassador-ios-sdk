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
#import "LoadingScreen.h"
#import "UIAlertController+CancelAlertController.h"

@interface AmbassadorLoginViewController() <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView * loginMasterView;
@property (nonatomic, strong) IBOutlet UITextField * tfUserName;
@property (nonatomic, strong) IBOutlet UITextField * tfPassword;
@property (nonatomic, strong) IBOutlet UIButton * btnLogin;
@property (nonatomic, strong) IBOutlet UIButton * btnNoAccount;
@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;

@end


@implementation AmbassadorLoginViewController


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [self setupUI];
    [self registerForKeyboardNotificaitons];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [LoadingScreen rotateLoadingScreenForView:self.view];
}


#pragma mark - Actions

- (IBAction)performLogin:(id)sender {
    [self.view endEditing:YES];
    [self makeAmbassadorLoginRequest];
}

- (IBAction)dontHaveAnAccountTapped:(id)sender {
    [self performSegueWithIdentifier:@"noAccountSegue" sender:self];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Handles return key for user name and password fields
    if ([textField isEqual:self.tfUserName]) {
        [self.tfUserName resignFirstResponder];
        [self.tfPassword becomeFirstResponder];
    } else if ([textField isEqual:self.tfPassword]) {
        [self.tfPassword resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - UI Functions

- (void)setupUI {
    // Login View
    self.loginMasterView.layer.cornerRadius = 4;
    
    // Login button
    self.btnLogin.layer.cornerRadius = 4;
}


#pragma mark - Keyboard Listener

- (void)registerForKeyboardNotificaitons {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notificaiton {
    CGRect keyboardFrame = [notificaiton.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat textfieldPosition = self.loginMasterView.frame.origin.y + self.loginMasterView.frame.size.height + 10;
    CGFloat difference = self.scrollView.frame.size.height - textfieldPosition;
    
    if (keyboardFrame.size.height > difference) {
        CGFloat newY = keyboardFrame.size.height - difference;
        [self.scrollView setContentOffset:CGPointMake(0, newY) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Resets the scrollview to original position
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - Helper Functions

- (void)makeAmbassadorLoginRequest {
    // Sets up request
    NSURL *ambassadorURL;
#if AMBPRODUCTION
    ambassadorURL = [NSURL URLWithString:@"https://api.getambassador.com/v2-auth/"];
#else
    ambassadorURL = [NSURL URLWithString:@"https://dev-ambassador-api.herokuapp.com/v2-auth/"];
#endif
    
    [LoadingScreen showLoadingScreenForView:self.view];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ambassadorURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *bodyDict = @{@"email" : self.tfUserName.text, @"password" : self.tfPassword.text};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil];
    
    // Makes network call
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [LoadingScreen hideLoadingScreenForView:self.view];
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        if (!error && [self isValidStatusCode:statusCode]) {
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            [self handleSuccessfulLogin:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        } else {
            UIAlertController *cancelAlert = [UIAlertController cancelAlertWithTitle:@"Could not Sign In" message:@"There was an error while signing in. Please try again." cancelMessage:@"Okay"];
            [self presentViewController:cancelAlert animated:YES completion:nil];
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
    [DefaultsHandler setSDKToken:dictionary[@"company"][@"sdk_token"]];
    [DefaultsHandler setUniversalID:dictionary[@"company"][@"universal_id"]];
    [DefaultsHandler setUniversalToken:dictionary[@"company"][@"universal_token"]];
    
    [self.delegate userSuccessfullyLoggedIn];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
