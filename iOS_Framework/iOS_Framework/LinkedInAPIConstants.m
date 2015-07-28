//
//  LinkedInAPIConstants.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkedInAPIConstants.h"

// Keys in JSON responses from LinkedIn
NSString * const LKDN_ERROR_DICT_KEY = @"error";
NSString * const LKDN_CODE_DICT_KEY = @"code";
NSString * const LKDN_EXPIRES_DICT_KEY = @"expires_in";
NSString * const LKDN_OAUTH_TOKEN_KEY = @"access_token";

// Urls
NSString * const LKDN_AUTH_URL = @"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=75sew7u54h2hn0&redirect_uri=http://localhost:2999/&state=987654321&scope=r_basicprofile%20w_share";
NSString * const LKDN_AUTH_CALLBACK_URL = @"http://localhost:2999/";
NSString * const LKDN_REQUEST_OAUTH_TOKEN_URL = @"https://www.linkedin.com/uas/oauth2/accessToken";

NSString* lkdnBuildRequestTokenHTTPBody(NSString* key)
{
    return [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=http://localhost:2999/&client_id=75sew7u54h2hn0&client_secret=pX72VGlgpjMnzTGs", key];
}
