//
//  LinkedInShare.m
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import "LinkedInShare.h"
#import "LinkedInAPIConstants.h"
#import "Constants.h"
#import "ShareServicesConstants.h"
#import "Utilities.h"

@interface LinkedInShare ()

@end

@implementation LinkedInShare

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LinkedIn";
    self.textView.text = self.defaultMessage;
}

- (void)didSelectPost
{
    DLog();
    NSDictionary *authKey = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AMB_LINKEDIN_USER_DEFAULTS_KEY];
    
    NSURL *url = [NSURL URLWithString:LKDN_SHARE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authKey[LKDN_OAUTH_TOKEN_KEY]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    NSDictionary *payload = @{ LKDN_COMMENT_DICT_KEY : [NSString stringWithFormat:@"%@ %@", self.textView.text, self.shortURL], LKDN_VISIBILITY_DICT_KEY : @{ LKDN_CODE_DICT_KEY : @"connections-only" } };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              DLog(@"%ld", (long)((NSHTTPURLResponse *)response).statusCode);
              //Check for 2xx status codes
              if (((NSHTTPURLResponse *)response).statusCode >= 200 &&
                  ((NSHTTPURLResponse *)response).statusCode < 300)
              {
                  DLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                  [self.delegate userDidPostFromService:LINKEDIN_TITLE];
              }
              else if (((NSHTTPURLResponse *)response).statusCode == 400)
              {
                  DLog(@"LinkedIn 400 error");
                  [self.delegate networkError:@"Posting Error" message:@"You may have already posted this comment"];
              }
              else if (((NSHTTPURLResponse *)response).statusCode == 401)
              {
                  DLog(@"LinkedIn 401 error");
                  [self.delegate userMustReauthenticate];
              }
              else
              {
                  DLog();
                  [self.delegate networkError:@"Posting Error" message:@"Your post couldn't be completed do to a network error"];
              }
          }
          else
          {
              DLog();
              [self.delegate networkError:@"Posting Error" message:@"Your post couldn't be completed do to a network error"];
          }
      }];
    [task resume];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectCancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
